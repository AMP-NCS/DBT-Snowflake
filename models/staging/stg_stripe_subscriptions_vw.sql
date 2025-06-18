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


        --EXCLUDE INCOMPLETE STATUS TYPES AS THESE WERE NEVER TRULY CREATED
        WHERE sub.status NOT IN ('incomplete_expired', 'incomplete')

        --EXCLUDE ANY TOKEN PLANS AS THEY WILL BE CAPTURED IN THE NEXT SUBQUERY (IF NOT MIGRATED, IN WHICH CASE WE WANT TO IGNORE THEM)
        AND NOT EXISTS (
            SELECT 1
            FROM {{ source('INTERNAL', 'TOKEN_MIGRATION_PLAN_LOCATION') }} AS t
            WHERE t.subscription_id = sub.subscription_id
        )

    ),

    --used to track override locations
    loc_override AS (
        SELECT
            subscription_id,
            --    INITIAL_LOCATION AS initial_location_id, 
            override_location AS override_location_id
        FROM {{ source('INTERNAL','LOCATION_OVERRIDE') }}
    ),

    --used to track signup location and signup user.  only keep records where customer is not assigned to signup: created_by_id <> customer_user_external_id
    sub_signups AS (
        SELECT
            id                           AS signup_id,
            tenant__r__external_id__c    AS tenant_id,
            closest_location_external_id AS signup_closest_location_id,
            --    LAST_MODIFIED,
            subscription_id,
            --    LATITUDE,
            --    LONGITUDE,
            --    CUSTOMER_USER_EXTERNAL_ID,
            created_by_id                AS signup_created_by_user_id,
            --    PRICE_ID,
            CAST(created AS DATE)        AS signup_created_date
        --    LAST_MODIFIED_BY_ID
        FROM {{ source('GENERAL', 'SUBSCRIPTION_SIGN_UP') }}
        WHERE created_by_id <> customer_user_external_id
    ),

    migrated AS (
        SELECT
            migrated_plans.stripe_subscription_id,
            imported_plans.tenant__r__external_id__c AS tenant_id,
            imported_plans.pos_location              AS migrated_pos_location_code
        --    token_plans.subscription_id AS token_plans_to_ignore_subscription_id
        FROM {{ source('GENERAL', 'POS_PLAN_MIGRATED') }} AS migrated_plans
            INNER JOIN {{ source('GENERAL', 'POS_PLAN_IMPORTED') }} AS imported_plans
                ON
                    migrated_plans.pos_plan_id = imported_plans.pos_plan_id
                    AND migrated_plans.tenant__r__external_id__c = imported_plans.tenant__r__external_id__c
    -- LEFT JOIN {{ source('INTERNAL', 'TOKEN_MIGRATION_PLAN_LOCATION') }} token_plans
    --     ON imported_plans.pos_plan_id = token_plans.pos_plan_id
    --     AND imported_plans.tenant__r__external_id__c = token_plans.tenant_id
    )

SELECT
    source_cte.tenant__r__external_id__c                                                 AS tenant_id,
    source_cte.subscription_id,
    customer_id                                                                          AS stripe_customer_id,
    status,
    cancel_at_period_end                                                                 AS cancel_at_period_end_flag,
    coupon_id,
    promotion_code_id,
    tax_rate,
    downgrade_price_id,
    source_cte.account_id,
    signup_zip_code,
    tax_location_override_id,
    cancellation_details_reason,
    aaa_membership_number,
    source_cte.location_id                                                               AS subscription_location_id,
    created_by_admin_id,

    -- DateTime and corresponding Date fields grouped together
    -- current_period_end                                                                   AS current_period_end_datetime,
    CAST(current_period_end AS DATE)                                                     AS current_period_end_date,

    -- current_period_start                                                                 AS current_period_start_datetime,
    CAST(current_period_start AS DATE)                                                   AS current_period_start_date,

    -- billing_cycle_anchor                                                                 AS billing_cycle_anchor_datetime,
    CAST(billing_cycle_anchor AS DATE)                                                   AS billing_cycle_anchor_date,

    -- cancel_at                                                                            AS plan_cancel_request_datetime,
    CAST(cancel_at AS DATE)                                                              AS plan_cancel_request_date,

    -- canceled_at                                                                          AS plan_cancel_scheduled_for_datetime,
    CAST(canceled_at AS DATE)
        AS plan_cancel_scheduled_for_date,

    -- ended_at                                                                             AS plan_end_datetime,
    CAST(ended_at AS DATE)                                                               AS plan_end_date,

    -- start_date                                                                           AS plan_start_datetime,
    CAST(start_date AS DATE)                                                             AS plan_start_date,

    source_cte.subscription_created
        AS subscription_created_datetime,
    CAST(source_cte.subscription_created AS DATE)                                        AS subscription_created_date,

    source_cte.created                                                                   AS created_datetime,
    CAST(source_cte.created AS DATE)                                                     AS created_date,

    source_cte.last_modified                                                             AS last_modified_datetime,
    CAST(source_cte.last_modified AS DATE)                                               AS last_modified_date,

    -- downgrade_expiration                                                                 AS downgrade_expiration_datetime,
    CAST(downgrade_expiration AS DATE)                                                   AS downgrade_expiration_date,

    -- auto_cancel_date                                                                     AS auto_cancel_date_datetime,
    CAST(auto_cancel_date AS DATE)                                                       AS auto_cancel_date,

    -- pause_request_date                                                                   AS pause_request_date_datetime,
    CAST(pause_request_date AS DATE)                                                     AS pause_request_date,

    -- pause_effective_date                                                                 AS pause_effective_date_datetime,
    CAST(pause_effective_date AS DATE)                                                   AS pause_effective_date,

    -- pause_end_date                                                                       AS pause_end_date_datetime,
    CAST(pause_end_date AS DATE)                                                         AS pause_end_date,

    -- Calculated fields
    CAST(IFF(downgrade_expiration >= SYSDATE(), downgrade_expiration, NULL) AS DATE)     AS pending_downgrade_date,

    CONCAT(source_cte.tenant__r__external_id__c, '-', source_cte.location_id)            AS subscription_unique_tenant_location_id,
    CASE
        WHEN status = 'canceled' THEN 'Canceled'
        WHEN status = 'past_due' THEN 'Past Due'
        WHEN status = 'unpaid' THEN 'Unpaid'
        WHEN pause_effective_date < SYSDATE() THEN 'Paused'
        WHEN pause_effective_date > SYSDATE() THEN 'Pending Pause'
        WHEN cancel_at_period_end = TRUE THEN 'Pending Cancelation'
        ELSE 'Current'
    END                                                                                  AS new_status,


    loc_override.override_location_id,
    CONCAT(source_cte.tenant__r__external_id__c, '-', loc_override.override_location_id) AS override_unique_tenant_location_id,

    sub_signups.signup_created_by_user_id,
    sub_signups.signup_closest_location_id,
    CONCAT(sub_signups.tenant_id, '-', sub_signups.signup_closest_location_id)           AS signup_unique_tenant_location_id,

    migrated.migrated_pos_location_code,
    CONCAT(migrated.tenant_id, '-', migrated.migrated_pos_location_code)                 AS migrated_unique_tenant_location_code,
    IFF(migrated.stripe_subscription_id IS NOT NULL, TRUE, FALSE)                        AS migrated_plan_flag,
    
    CONCAT(vehicle.license_plate_number, ',', vehicle.license_plate_state)               AS license_plate_id


FROM source_cte

    LEFT OUTER JOIN loc_override
        ON source_cte.subscription_id = loc_override.subscription_id

    LEFT OUTER JOIN sub_signups
        ON source_cte.subscription_id = sub_signups.subscription_id

    LEFT OUTER JOIN migrated
        ON
            source_cte.subscription_id = migrated.stripe_subscription_id
            AND source_cte.tenant__r__external_id__c = migrated.tenant_id

    LEFT OUTER JOIN {{ source('GENERAL', 'VEHICLE') }} AS vehicle
        ON source_cte.subscription_id = vehicle.subscription_id