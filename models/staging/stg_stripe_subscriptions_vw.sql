{{ config(materialized='view') }}

WITH source_cte AS (
    SELECT
        tenant__r__external_id__c,
        subscription_id,
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
        subscription_created,
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
    FROM {{ source('REPORTING','STRIPE_SUBSCRIPTIONS') }}
),

loc_override AS (
    SELECT
        subscription_id,
        initial_location,
        override_location
    FROM {{ source('INTERNAL','LOCATION_OVERRIDES') }}
),

sub_signups AS (
    SELECT
        subscription_id,
        closest_location_external_id,
        customer_user_external_id,
        created_by_id
    FROM {{ source('GENERAL', 'SUBSCRIPTION_SIGN_UP') }}
),

migrated AS (
    SELECT
        -- id,
        tenant__r__external_id__c,
        -- amp_user_id,
        stripe_subscription_id,
        pos_plan_id
        -- created,
        -- last_modified,
        -- amp_vehicle_id,
        -- migration_complete,
        -- created_by_id,
        -- last_modified_by_id,
        -- pos_plan_imported_id
    FROM {{ source('GENERAL', 'POS_PLAN_MIGRATED') }}
),

imported AS (
    SELECT
        -- id,
        tenant__r__external_id__c,
        pos_plan_id,
        -- pos_customer_id,
        -- amp_price_id,
        -- license_plate_number,
        -- license_plate_state,
        -- rfid,
        -- next_billing_date,
        -- pos_system,
        pos_location
        -- pos_plan_name,
        -- created,
        -- last_modified,
        -- canceled_by_amp,
        -- canceled_by_amp_failed,
        -- canceled,
        -- canceled_by_amp_error,
        -- created_by_id,
        -- last_modified_by_id,
        -- integration_id,
        -- canceled_checked_by_amp,
        -- credit_card_ending_digits,
        -- canceled_by_amp_warning,
        -- canceled_checked_by_amp_failed,
        -- canceled_checked_by_amp_error,
        -- comments,
        -- contact_id,
        -- pos_customer_imported_id,
        -- is_prepaid_plan,
        -- cancel_check_by_amp_allowed,
        -- amp_legacy_plan_id
    FROM {{ source('GENERAL', 'POS_PLAN_IMPORTED') }}
),

token_migration AS (
    SELECT
        subscription_id,
        pos_plan_id,
        tenant_id,
        location_id
    FROM {{ source('INTERNAL', 'TOKEN_MIGRATION_PLAN_LOCATION') }}
),

vehicle AS (
    SELECT
        subscription_id,
        license_plate_state,
        license_plate_number,
        CONCAT(vehicle.license_plate_number,',',vehicle.license_plate_state) AS license_plate_id,
        tenant__r__external_id__c
    FROM {{ source('GENERAL', 'VEHICLE') }}
),

renamed_cte AS (
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

        subscription_created                     AS subscription_created_datetime,
        cast(subscription_created AS date)       AS subscription_created_date,

        created                                  AS created_datetime,
        cast(created AS date)                    AS created_date,

        last_modified                            AS last_modified_datetime,
        cast(last_modified AS date)              AS last_modified_date,

        downgrade_price_id,

        downgrade_expiration                     AS downgrade_expiration_datetime,
        cast(downgrade_expiration AS date)       AS downgrade_expiration_date,

        auto_cancel_date                         AS auto_cancel_date_datetime,
        cast(auto_cancel_date AS date)           AS auto_cancel_date_date,

        account_id,

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
                THEN created_by_id
        END                                      AS sign_up_by_user_id,

        migrated.stripe_subscription_id         AS migrated_subscription_id,
        imported.pos_location                   AS migrated_location_cd,
        imported.TENANT__R__EXTERNAL_ID__C      AS migrated_tenant_id,


        token_migration.subscription_id         AS token_migration_subscription_id,

        created_by_admin_id,

        vehicle.license_plate_id

    FROM source_cte

        LEFT JOIN loc_override
            ON source_cte.subscription_id = loc_override.subscription_id

        LEFT JOIN sub_signups
            ON source_cte.subscription_id = sub_signups.subscription_id

        LEFT JOIN migrated
            ON source_cte.subscription_id = migrated.stripe_subscription_id

        LEFT JOIN imported 
            ON migrated.pos_plan_id = imported.pos_plan_id
            AND migrated.tenant__r__external_id__c = imported.tenant__r__external_id__c

        LEFT JOIN token_migration
            ON imported.pos_plan_id = token_migration.pos_plan_id
            AND imported.tenant__r__external_id__c = token_migration.tenant_id

        LEFT JOIN vehicle
            ON source_cte.subscription_id = vehicle.subscription_id
),

final_cte AS (
    SELECT * FROM renamed_cte
)

SELECT * FROM final_cte
