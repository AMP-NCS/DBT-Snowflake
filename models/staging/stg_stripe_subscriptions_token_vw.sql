{{ config(materialized='view') }}

WITH source_cte AS (
    SELECT
        sub.tenant__r__external_id__c,
        sub.subscription_id,
        customer_id,
        cancel_at_period_end,
        current_period_end,
        current_period_start,
        status,
        billing_cycle_anchor,
        cancel_at,
        canceled_at,
        ended_at,
        start_date,
        coupon_id,
        promotion_code_id,
        tax_rate,
        sub.subscription_created,
        created,
        last_modified,
        downgrade_price_id,
        downgrade_expiration,
        auto_cancel_date,
        account_id,
        pause_request_date,
        pause_effective_date,
        pause_end_date,
        location_id,
        created_by_admin_id,
        signup_zip_code,
        tax_location_override_id,
        cancellation_details_reason,
        aaa_membership_number
    FROM {{ source('REPORTING','STRIPE_SUBSCRIPTIONS') }} sub
--EXCLUDE INCOMPLETE STATUS TYPES AS THESE WERE NEVER TRULY CREATED
    WHERE status NOT IN ('incomplete_expired', 'incomplete') 
--EXCLUDE ANY TOKEN PLANS AS THEY WILL BE CAPTURED IN THE NEXT SUBQUERY (IF NOT MIGRATED, IN WHICH CASE WE WANT TO IGNORE THEM)
    AND EXISTS (
        SELECT 1
            FROM {{ source('INTERNAL', 'TOKEN_MIGRATION_PLAN_LOCATION') }} t
            WHERE t.subscription_id = sub.subscription_id)
    
)

SELECT
    source_cte.tenant__r__external_id__c     AS tenant_id,
    source_cte.subscription_id               AS stripe_subscription_id,
    customer_id                              AS stripe_customer_id,
    cancel_at_period_end                     AS cancel_at_period_end_flg,

    current_period_end                       AS current_period_end_datetime,
    cast(current_period_end AS date)         AS current_period_end_date,

    current_period_start                     AS current_period_start_datetime,
    cast(current_period_start AS date)       AS current_period_start_date,

    status,

    billing_cycle_anchor                     AS billing_cycle_anchor_datetime,
    cast(billing_cycle_anchor AS date)       AS billing_cycle_anchor_date,

    cancel_at                                AS cancel_datetime,
    cast(cancel_at AS date)                  AS cancel_date,

    canceled_at                              AS canceled_datetime,
    cast(canceled_at AS date)                AS canceled_date,

    ended_at                                 AS ended_datetime,
    cast(ended_at AS date)                   AS ended_date,

    start_date                               AS start_datetime,
    cast(start_date AS date)                 AS start_date,

    coupon_id,
    promotion_code_id,
    tax_rate,

    source_cte.subscription_created                     AS subscription_created_datetime,
    cast(source_cte.subscription_created AS date)       AS subscription_created_date,

    source_cte.created                                  AS created_datetime,
    cast(source_cte.created AS date)                    AS created_date,

    source_cte.last_modified                            AS last_modified_datetime,
    cast(source_cte.last_modified AS date)              AS last_modified_date,

    downgrade_price_id,

    downgrade_expiration                     AS downgrade_expiration_datetime,
    cast(downgrade_expiration AS date)       AS downgrade_expiration_date,

    auto_cancel_date                         AS auto_cancel_date_datetime,
    cast(auto_cancel_date AS date)           AS auto_cancel_date_date,

    source_cte.account_id,

    pause_request_date                       AS pause_request_date_datetime,
    cast(pause_request_date AS date)         AS pause_request_date_date,

    pause_effective_date                     AS pause_effective_date_datetime,
    cast(pause_effective_date AS date)       AS pause_effective_date_date,

    pause_end_date                           AS pause_end_date_datetime,
    cast(pause_end_date AS date)             AS pause_end_date_date,

    signup_zip_code,

    tax_location_override_id,
    cancellation_details_reason,
    aaa_membership_number,

    source_cte.location_id,

    loc_override.override_location           AS override_location_id,

    sub_signups.subscription_id              AS signup_subscription_id,
    sub_signups.closest_location_external_id AS signup_closest_location_id,
    CASE
        WHEN sub_signups.created_by_id <> sub_signups.customer_user_external_id
            THEN sub_signups.created_by_id
    END                                      AS sign_up_by_user_id,

    migrated.stripe_subscription_id         AS migrated_subscription_id,
    imported.pos_location                   AS migrated_location_cd,
    imported.TENANT__R__EXTERNAL_ID__C      AS migrated_tenant_id,

    token_migration.subscription_id         AS token_migration_subscription_id,

    created_by_admin_id,

    CONCAT(vehicle.license_plate_number,',',vehicle.license_plate_state) AS license_plate_id,

FROM source_cte

LEFT JOIN {{ source('INTERNAL','LOCATION_OVERRIDES') }} AS loc_override
    ON source_cte.subscription_id = loc_override.subscription_id

LEFT JOIN {{ source('GENERAL', 'SUBSCRIPTION_SIGN_UP') }} AS sub_signups
    ON source_cte.subscription_id = sub_signups.subscription_id

LEFT JOIN {{ source('GENERAL', 'POS_PLAN_MIGRATED') }} AS migrated
    ON source_cte.subscription_id = migrated.stripe_subscription_id

LEFT JOIN {{ source('GENERAL', 'POS_PLAN_IMPORTED') }} AS imported
    ON migrated.pos_plan_id = imported.pos_plan_id
    AND migrated.tenant__r__external_id__c = imported.tenant__r__external_id__c

LEFT JOIN {{ source('INTERNAL', 'TOKEN_MIGRATION_PLAN_LOCATION') }} AS token_migration
    ON imported.pos_plan_id = token_migration.pos_plan_id
    AND imported.tenant__r__external_id__c = token_migration.tenant_id

LEFT JOIN {{ source('GENERAL', 'VEHICLE') }} AS vehicle
    ON source_cte.subscription_id = vehicle.subscription_id
