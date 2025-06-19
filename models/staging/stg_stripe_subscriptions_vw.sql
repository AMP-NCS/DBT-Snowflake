--DBT Model
--2025-05-23 Original model created by Patrick Callahan (PC)
--2025-06-18 PC updated to optimize query

{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            sub.tenant__r__external_id__c,
            sub.subscription_id,
            sub.customer_id,
            sub.cancel_at_period_end,
            sub.current_period_end,
            sub.current_period_start,
            sub.status,
            sub.billing_cycle_anchor,
            sub.cancel_at,
            sub.canceled_at,
            sub.ended_at,
            sub.start_date,
            sub.coupon_id,
            sub.promotion_code_id,
            sub.tax_rate,
            sub.subscription_created,
            sub.created,
            sub.last_modified,
            sub.downgrade_price_id,
            sub.downgrade_expiration,
            sub.auto_cancel_date,
            sub.account_id,
            sub.pause_request_date,
            sub.pause_effective_date,
            sub.pause_end_date,
            sub.location_id,
            sub.created_by_admin_id,
            sub.signup_zip_code,
            sub.tax_location_override_id,
            sub.cancellation_details_reason,
            sub.aaa_membership_number

        FROM {{ source('REPORTING','STRIPE_SUBSCRIPTIONS') }} AS sub
        WHERE sub.status NOT IN ('incomplete_expired', 'incomplete')
    ),

    -- Get token migration subscriptions to exclude
    token_migrations AS (
        SELECT DISTINCT subscription_id
        FROM {{ source('INTERNAL', 'TOKEN_MIGRATION_PLAN_LOCATION') }}
    ),

    -- Pre-aggregate migrated data to avoid multiple table scans
    migrated AS (
        SELECT
            migrated_plans.stripe_subscription_id,
            migrated_plans.tenant__r__external_id__c AS tenant_id,
            imported_plans.pos_location              AS migrated_pos_location_code
        FROM {{ source('GENERAL', 'POS_PLAN_MIGRATED') }} AS migrated_plans
            INNER JOIN {{ source('GENERAL', 'POS_PLAN_IMPORTED') }} AS imported_plans
                ON
                    migrated_plans.pos_plan_id = imported_plans.pos_plan_id
                    AND migrated_plans.tenant__r__external_id__c = imported_plans.tenant__r__external_id__c
    ),

    -- Pre-filter signup data
    sub_signups AS (
        SELECT
            id                           AS signup_id,
            tenant__r__external_id__c    AS tenant_id,
            closest_location_external_id AS signup_closest_location_id,
            subscription_id,
            created_by_id                AS signup_created_by_user_id,
            CAST(created AS DATE)        AS signup_created_date
        FROM {{ source('GENERAL', 'SUBSCRIPTION_SIGN_UP') }}
        WHERE created_by_id <> customer_user_external_id
    ),

    -- Get location overrides
    loc_override AS (
        SELECT
            subscription_id,
            override_location AS override_location_id
        FROM {{ source('INTERNAL','LOCATION_OVERRIDE') }}
    ),

    -- Get vehicle data
    vehicle_data AS (
        SELECT
            subscription_id,
            CONCAT(license_plate_number, ',', license_plate_state) AS license_plate_id
        FROM {{ source('GENERAL', 'VEHICLE') }}
    )

SELECT
    -- Basic subscription fields
    s.tenant__r__external_id__c                            AS tenant_id,
    s.subscription_id,
    s.customer_id                                          AS stripe_customer_id,
    s.status,
    s.cancel_at_period_end                                 AS cancel_at_period_end_flag,
    s.coupon_id,
    s.promotion_code_id,
    s.tax_rate,
    s.downgrade_price_id,
    s.account_id,
    s.signup_zip_code,
    s.tax_location_override_id,
    s.cancellation_details_reason,
    s.aaa_membership_number,
    s.location_id                                          AS subscription_location_id,
    s.created_by_admin_id,

    -- Date fields (consolidated CAST operations)
    CAST (s.current_period_end AS DATE)                    AS current_period_end_date,
    CAST (s.current_period_start AS DATE)                  AS current_period_start_date,
    CAST (s.billing_cycle_anchor AS DATE)                  AS billing_cycle_anchor_date,
    CAST (s.cancel_at AS DATE)                             AS plan_cancel_request_date,
    CAST (s.canceled_at AS DATE)                           AS plan_cancel_scheduled_for_date,
    CAST (s.ended_at AS DATE)                              AS plan_end_date,
    CAST (s.start_date AS DATE)                            AS plan_start_date,
    s.subscription_created                                 AS subscription_created_datetime,
    CAST (s.subscription_created AS DATE)                  AS subscription_created_date,
    s.created                                              AS created_datetime,
    CAST (s.created AS DATE)                               AS created_date,
    s.last_modified                                        AS last_modified_datetime,
    CAST (s.last_modified AS DATE)                         AS last_modified_date,
    CAST (s.downgrade_expiration AS DATE)                  AS downgrade_expiration_date,
    CAST (s.auto_cancel_date AS DATE)                      AS auto_cancel_date,
    CAST (s.pause_request_date AS DATE)                    AS pause_request_date,
    CAST (s.pause_effective_date AS DATE)                  AS pause_effective_date,
    CAST (s.pause_end_date AS DATE)                        AS pause_end_date,

    -- Calculated fields (optimized CASE statement)
    CASE
        WHEN s.downgrade_expiration >= CURRENT_DATE()
            THEN CAST (s.downgrade_expiration AS DATE)
    END                                                    AS pending_downgrade_date,

    -- Concatenated fields (using || for better performance)
    s.tenant__r__external_id__c || '-' || s.location_id    AS subscription_unique_tenant_location_id,

    -- Optimized status logic
    CASE
        WHEN s.status IN ('canceled', 'past_due', 'unpaid')
            THEN
                CASE s.status
                    WHEN 'canceled' THEN 'Canceled'
                    WHEN 'past_due' THEN 'Past Due'
                    WHEN 'unpaid' THEN 'Unpaid'
                END
        WHEN s.pause_effective_date < CURRENT_DATE() THEN 'Paused'
        WHEN s.pause_effective_date > CURRENT_DATE() THEN 'Pending Pause'
        WHEN s.cancel_at_period_end = TRUE THEN 'Pending Cancelation'
        ELSE 'Current'
    END                                                    AS new_status,

    -- Location override fields
    lo.override_location_id,
    CASE
        WHEN lo.override_location_id IS NOT NULL
            THEN s.tenant__r__external_id__c || '-' || lo.override_location_id
    END                                                    AS override_unique_tenant_location_id,

    -- Signup fields
    ss.signup_created_by_user_id,
    ss.signup_closest_location_id,
    CASE
        WHEN ss.signup_closest_location_id IS NOT NULL
            THEN ss.tenant_id || '-' || ss.signup_closest_location_id
    END                                                    AS signup_unique_tenant_location_id,

    -- Migration fields
    m.migrated_pos_location_code,
    CASE
        WHEN m.migrated_pos_location_code IS NOT NULL
            THEN m.tenant_id || '-' || m.migrated_pos_location_code
    END                                                    AS migrated_unique_tenant_location_code,

    COALESCE (m.stripe_subscription_id IS NOT NULL, FALSE) AS migrated_plan_flag,

    -- Vehicle data
    v.license_plate_id

FROM source_cte AS s
    -- Exclude token migrations using LEFT JOIN instead of NOT EXISTS
    LEFT OUTER JOIN token_migrations AS tm
        ON s.subscription_id = tm.subscription_id
    LEFT OUTER JOIN loc_override AS lo
        ON s.subscription_id = lo.subscription_id
    LEFT OUTER JOIN sub_signups AS ss
        ON s.subscription_id = ss.subscription_id
    LEFT OUTER JOIN migrated AS m
        ON
            s.subscription_id = m.stripe_subscription_id
            AND s.tenant__r__external_id__c = m.tenant_id
    LEFT OUTER JOIN vehicle_data AS v
        ON s.subscription_id = v.subscription_id

WHERE tm.subscription_id IS NULL  -- Exclude token migrations