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
        -- AND NOT EXISTS (
        --     SELECT 1
        --     FROM {{ source('INTERNAL', 'TOKEN_MIGRATION_PLAN_LOCATION') }} AS t
        --     WHERE t.subscription_id = sub.subscription_id
        -- )

    )

SELECT
    source_cte.tenant__r__external_id__c                                              AS tenant_id,
    source_cte.subscription_id                                                        AS stripe_subscription_id,
    customer_id                                                                       AS stripe_customer_id,

    status,

    cancel_at_period_end                                                              AS cancel_at_period_end_flag,

    -- current_period_end                                                                AS current_period_end_datetime,
    CAST(current_period_end AS date)                                                  AS current_period_end_date,

    -- current_period_start                                                              AS current_period_start_datetime,
    CAST(current_period_start AS date)                                                AS current_period_start_date,

    -- billing_cycle_anchor                                                              AS billing_cycle_anchor_datetime,
    CAST(billing_cycle_anchor AS date)                                                AS billing_cycle_anchor_date,

    -- cancel_at                                                                         AS plan_cancel_request_datetime,
    CAST(cancel_at AS date)                                                           AS plan_cancel_request_date,

    -- canceled_at                                                                       AS plan_cancel_scheduled_for_datetime,
    CAST(canceled_at AS date)                                                         AS plan_cancel_scheduled_for_date,

    -- ended_at                                                                          AS plan_end_datetime,
    CAST(ended_at AS date)                                                            AS plan_end_date,

    -- start_date                                                                        AS plan_start_datetime,
    CAST(start_date AS date)                                                          AS plan_start_date,

    coupon_id,
    promotion_code_id,

    tax_rate,

    -- source_cte.subscription_created                                                   AS subscription_created_datetime,
    CAST(source_cte.subscription_created AS date)                                     AS subscription_created_date,

    -- source_cte.created                                                                AS created_datetime,
    CAST(source_cte.created AS date)                                                  AS created_date,

    -- source_cte.last_modified                                                          AS last_modified_datetime,
    CAST(source_cte.last_modified AS date)                                            AS last_modified_date,

    downgrade_price_id,

    -- downgrade_expiration                                                              AS downgrade_expiration_datetime,
    CAST(downgrade_expiration AS date)                                                AS downgrade_expiration_date,
    CAST(IFF(downgrade_expiration >= SYSDATE(), downgrade_expiration, NULL) AS date)  AS pending_downgrade_date,

    -- auto_cancel_date                                                                  AS auto_cancel_date_datetime,
    CAST(auto_cancel_date AS date)                                                    AS auto_cancel_date,

    source_cte.account_id,

    -- pause_request_date                                                                AS pause_request_date_datetime,
    CAST(pause_request_date AS date)                                                  AS pause_request_date,

    -- pause_effective_date                                                              AS pause_effective_date_datetime,
    CAST(pause_effective_date AS date)                                                AS pause_effective_date,

    -- pause_end_date                                                                    AS pause_end_date_datetime,
    CAST(pause_end_date AS date)                                                      AS pause_end_date,

    signup_zip_code,
    tax_location_override_id,

    cancellation_details_reason,
    aaa_membership_number,

    source_cte.location_id                                                            AS subscription_location_id,

    loc_override.override_location                                                    AS override_location_id,
    sub_signups.subscription_id                                                       AS signup_subscription_id,

    sub_signups.closest_location_external_id                                          AS signup_location_id,
    migrated.stripe_subscription_id                                                   AS migrated_subscription_id,

    imported.pos_location                                                             AS migrated_location_code,

    imported.tenant__r__external_id__c                                                AS migrated_tenant_id,
    created_by_admin_id,

    CASE
        WHEN status = 'canceled' THEN 'Canceled'
        WHEN status = 'past_due' THEN 'Past Due'
        WHEN status = 'unpaid' THEN 'Unpaid'
        WHEN pause_effective_date < SYSDATE() THEN 'Paused'
        WHEN pause_effective_date > SYSDATE() THEN 'Pending Pause'
        WHEN cancel_at_period_end = TRUE THEN 'Pending Cancelation'
        ELSE 'Current'
    END                                                                               AS new_status,

    CONCAT(source_cte.tenant__r__external_id__c, '-', source_cte.location_id)           AS subscription_unique_tenant_location_id,
    CONCAT(source_cte.tenant__r__external_id__c, '-', loc_override.override_location)   AS override_unique_tenant_location_id,
    CONCAT(sub_signups.tenant__r__external_id__c, '-', closest_location_external_id)    AS signup_unique_tenant_location_id,
    CONCAT(imported.tenant__r__external_id__c, '-', imported.pos_location)              AS migrated_unique_tenant_location_code,

    IFF(migrated.stripe_subscription_id IS NOT NULL, TRUE, FALSE)                     AS migrated_plan_flag,

    CASE
        WHEN sub_signups.created_by_id <> sub_signups.customer_user_external_id
            THEN sub_signups.created_by_id
    END                                                                               AS sign_up_by_user_id,

    token_migration.subscription_id         AS token_migration_subscription_id,


FROM source_cte

    LEFT OUTER JOIN {{ source('INTERNAL','LOCATION_OVERRIDES') }} AS loc_override
        ON source_cte.subscription_id = loc_override.subscription_id

    LEFT OUTER JOIN {{ source('GENERAL', 'SUBSCRIPTION_SIGN_UP') }} AS sub_signups
        ON source_cte.subscription_id = sub_signups.subscription_id

    LEFT OUTER JOIN {{ source('GENERAL', 'POS_PLAN_MIGRATED') }} AS migrated
        ON source_cte.subscription_id = migrated.stripe_subscription_id

    LEFT OUTER JOIN {{ source('GENERAL', 'POS_PLAN_IMPORTED') }} AS imported
        ON
            migrated.pos_plan_id = imported.pos_plan_id
            AND migrated.tenant__r__external_id__c = imported.tenant__r__external_id__c

    LEFT JOIN {{ source('INTERNAL', 'TOKEN_MIGRATION_PLAN_LOCATION') }} AS token_migration
    ON imported.pos_plan_id = token_migration.pos_plan_id
    AND imported.tenant__r__external_id__c = token_migration.tenant_id