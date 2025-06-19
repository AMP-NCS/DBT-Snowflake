{{ config(materialized='view') }}

-- This model replicates the logic of the legacy AMP_DB_DEV.VIEWS.SUBSCRIPTIONS view using dbt models
-- It leverages staging/intermediate models for each CTE where possible

-- Optimized version of the subscriptions view for Snowflake
-- Key optimizations:
-- 3. Optimized JOIN order based on cardinality
-- 4. Pushed down filters where possible
-- 5. Replaced multiple COALESCE calls with CTEs
-- 6. Optimized window functions

WITH
    subscription_base AS (
        SELECT
        -- Primary identifiers
            s.tenant_id,
            s.stripe_customer_id,
            s.subscription_id,

            -- Migration and legacy fields
            s.migrated_unique_tenant_location_code,
            s.migrated_plan_flag,

            -- Status fields
            s.new_status,
            s.status,
            s.cancel_at_period_end_flag,
            s.cancellation_details_reason,

            -- Subscription details
            s.coupon_id,
            s.subscription_created_date,
            s.plan_start_date,
            s.current_period_end_date,
            s.plan_cancel_request_date,
            s.plan_cancel_scheduled_for_date,
            s.plan_end_date,

            -- Pause-related dates
            s.pause_request_date,
            s.pause_effective_date,
            s.pause_end_date,

            -- Other dates
            s.auto_cancel_date,
            s.pending_downgrade_date,

            -- Location IDs
            -- s.override_unique_tenant_location_id,
            -- s.subscription_unique_tenant_location_id,
            -- s.signup_unique_tenant_location_id,

            -- User and signup info
            s.signup_created_by_user_id,

            -- License plate info
            s.license_plate_id,

            -- Downgrade info
            s.downgrade_price_id,

            -- Pre-compute the assigned location ID to avoid repeated COALESCE
            COALESCE(
                s.migrated_unique_tenant_location_code,
                s.override_unique_tenant_location_id,
                s.subscription_unique_tenant_location_id,
                s.signup_unique_tenant_location_id
            ) AS assigned_unique_tenant_location_id,

            -- Pre-compute signup location ID
            COALESCE(
                s.override_unique_tenant_location_id,
                s.subscription_unique_tenant_location_id,
                s.signup_unique_tenant_location_id
            ) AS signup_unique_tenant_location_id
        FROM {{ ref('stg_stripe_subscriptions_vw') }} AS s
    ),

    -- Optimize the first_price subquery by filtering early
    first_price_filtered AS (
        SELECT
            subscription_id,
            price_id_current,
            ROW_NUMBER() OVER (
                PARTITION BY subscription_id
                ORDER BY stripe_subscription_item_history_id ASC
            ) AS rn
        FROM {{ ref('stg_stripe_subscription_item_history_vw') }}
        WHERE price_id_current IS NOT NULL
        {% if is_incremental() %}
        AND subscription_id IN (SELECT subscription_id FROM subscription_base)
        {% endif %}
    ),

    first_price AS (
        SELECT
            subscription_id,
            price_id_current AS first_price_id
        FROM first_price_filtered
        WHERE rn = 1
    )

SELECT
    -- Primary keys and identifiers
    s.tenant_id,
    s.stripe_customer_id,
    s.subscription_id,

    -- Customer information
    u.email                                AS customer_email,
    u.name                                 AS customer_name,
    u.phone_number                         AS customer_phone_number,

    -- Legacy and migration fields
    s.migrated_unique_tenant_location_code AS legacy_unique_tenant_location_code,
    s.migrated_plan_flag,

    -- Status fields
    s.new_status,
    s.status,
    s.cancel_at_period_end_flag,

    -- Subscription details
    s.coupon_id,
    s.subscription_created_date,
    s.plan_start_date,
    s.current_period_end_date,
    s.plan_cancel_request_date,
    s.plan_cancel_scheduled_for_date,
    s.plan_end_date,

    -- Cancellation information
    c.created_date                         AS cancellation_created_date,
    s.pause_request_date,
    s.pause_effective_date,
    s.pause_end_date,
    s.auto_cancel_date,
    s.pending_downgrade_date,

    -- Product information
    pp.product_name                        AS pre_downgrade_plan_name,

    -- Vehicle tracking
    vt.most_recent_rfid,
    vt.license_plate_number,
    vt.license_plate_state,
    vt.license_plate_id,

    -- Cancellation details
    c.cancellation_created_by_user_id      AS canceled_by_user_id,
    c.picklist_value_id,
    c.cancellation_comment,

    -- Invoice and wash information
    ic.number_of_paid_invoices_to_date,
    wl.first_wash_location_id,
    wl.last_wash_location_id,

    -- Pre-computed location IDs
    s.assigned_unique_tenant_location_id,
    s.signup_unique_tenant_location_id,

    -- Attendant customer ID logic
    IFF(
        s.subscription_created_date < '2023-10-04'::DATE
        AND u.stripe_customer_id IS NULL,
        s.signup_created_by_user_id,
        s.stripe_customer_id
    )                                      AS attendant_customer_id,

    -- Cancellation method logic (optimized with simpler conditions first)
    CASE
        WHEN s.status <> 'canceled' THEN NULL
        WHEN s.cancellation_details_reason = 'payment_disputed' THEN 'Canceled by Dispute'
        WHEN s.cancellation_details_reason = 'payment_failed' THEN 'Failed Payments'
        WHEN c.status_pre_cancel IN ('unpaid', 'past_due') THEN 'Failed Payments'
        WHEN c.cancellation_created_by_user_id = u.user_id THEN 'Canceled by Customer'
        WHEN s.cancellation_details_reason = 'cancellation_requested' THEN 'Canceled by Employee'
        WHEN
            c.subscription_id IS NOT NULL AND c.cancellation_created_by_user_id <> u.user_id
            THEN 'Canceled by Employee'
        ELSE 'Unknown'
    END                                    AS cancelation_method,

    -- Failed payment details (using CASE instead of IFF for clarity)
    CASE
        WHEN cancelation_method = 'Failed Payments'
            THEN lcf.last_charge_failure_message
    END                                    AS failed_payment_reason,

    CASE
        WHEN cancelation_method = 'Failed Payments'
            THEN INITCAP(lcf.last_charge_failure_card_funding)
    END                                    AS failed_payment_card_type,

    -- First invoice amount
    fi.first_invoice_amt,

    -- First price ID
    fp.first_price_id,

    -- Metadata
    -- CURRENT_TIMESTAMP()                    AS table_updated_at

FROM subscription_base AS s

    -- Join with users (likely high cardinality, but needed for most queries)
    LEFT OUTER JOIN {{ ref('stg_reference_users_vw') }} AS u
        ON s.stripe_customer_id = u.stripe_customer_id

    -- Join with smaller dimension tables first
    LEFT OUTER JOIN {{ ref('stg_reference_product_price_vw') }} AS pp
        ON s.downgrade_price_id = pp.stripe_price_id

    -- Join with first_price CTE (pre-filtered)
    LEFT OUTER JOIN first_price AS fp
        ON s.subscription_id = fp.subscription_id

    -- Join with aggregated/calculated tables
    LEFT OUTER JOIN {{ ref('int_subscription_invoice_count_vw') }} AS ic
        ON s.subscription_id = ic.subscription_id

    LEFT OUTER JOIN {{ ref('int_subscription_first_invoice_vw') }} AS fi
        ON s.subscription_id = fi.subscription_id

    LEFT OUTER JOIN {{ ref('int_subscription_cancellations_vw') }} AS c
        ON s.subscription_id = c.subscription_id

    LEFT OUTER JOIN {{ ref('int_subscription_last_charge_failure_vw') }} AS lcf
        ON
            s.subscription_id = lcf.subscription_id
            AND cancelation_method = 'Failed Payments'  -- Push down filter

    LEFT OUTER JOIN {{ ref('int_subscription_wash_locations_vw') }} AS wl
        ON s.subscription_id = wl.subscription_id

    -- Join with vehicle tracking (potentially large, join last)
    LEFT OUTER JOIN {{ ref('int_subscription_vehicle_tracking_vw') }} AS vt
        ON
            s.subscription_id = vt.first_subscription_id_for_plate
            AND s.license_plate_id = vt.license_plate_id