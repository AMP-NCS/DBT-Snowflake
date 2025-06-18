--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH source_cte AS (
    SELECT
        id,
        tenant__r__external_id__c,
        subscription_id,
        cancel_at_period_end_previous,
        cancel_at_period_end_current,
        status_previous,
        status_current,
        billing_cycle_anchor_previous,
        billing_cycle_anchor_current,
        cancel_at_previous,
        cancel_at_current,
        canceled_at_previous,
        canceled_at_current,
        coupon_id_previous,
        coupon_id_current,
        promotion_code_id_previous,
        promotion_code_id_current,
        tax_rate_previous,
        tax_rate_current,
        downgrade_price_id_previous,
        downgrade_price_id_current,
        downgrade_expiration_previous,
        downgrade_expiration_current,
        created,
        last_modified,
        auto_cancel_date_current,
        auto_cancel_date_previous,
        pause_request_date_current,
        pause_request_date_previous,
        pause_effective_date_current,
        pause_effective_date_previous,
        pause_end_date_current,
        pause_end_date_previous,
        cancellation_details_reason_current,
        cancellation_details_reason_previous,
        aaa_membership_number_current,
        aaa_membership_number_previous
    FROM {{ source('REPORTING', 'STRIPE_SUBSCRIPTION_HISTORIES') }}
),

renamed_cte AS (
    SELECT
        id                                          AS stripe_subscription_history_id,
        tenant__r__external_id__c                   AS tenant_id,
        subscription_id,

        cancel_at_period_end_previous               AS cancel_at_period_end_previous_flag,
        cancel_at_period_end_current                AS cancel_at_period_end_current_falg,

        status_previous,
        status_current,

        -- billing_cycle_anchor_previous               AS billing_cycle_anchor_previous_datetime,
        cast(billing_cycle_anchor_previous AS date) AS billing_cycle_anchor_previous_date,

        -- billing_cycle_anchor_current                AS billing_cycle_anchor_current_datetime,
        cast(billing_cycle_anchor_current AS date)  AS billing_cycle_anchor_current_date,

        -- cancel_at_previous                          AS cancel_at_previous_datetime,
        cast(cancel_at_previous AS date)            AS cancel_at_previous_date,

        -- cancel_at_current                           AS cancel_at_current_datetime,
        cast(cancel_at_current AS date)             AS cancel_at_current_date,

        -- canceled_at_previous                        AS canceled_at_previous_datetime,
        cast(canceled_at_previous AS date)          AS canceled_at_previous_date,

        -- canceled_at_current                         AS canceled_at_current_datetime,
        cast(canceled_at_current AS date)           AS canceled_at_current_date,

        coupon_id_previous,
        coupon_id_current,

        promotion_code_id_previous,
        promotion_code_id_current,

        tax_rate_previous,
        tax_rate_current,

        downgrade_price_id_previous,
        downgrade_price_id_current,

        -- downgrade_expiration_previous               AS downgrade_expiration_previous_datetime,
        cast(downgrade_expiration_previous AS date) AS downgrade_expiration_previous_date,

        -- downgrade_expiration_current                AS downgrade_expiration_current_datetime,
        cast(downgrade_expiration_current AS date)  AS downgrade_expiration_current_date,

        created                                     AS created_datetime,
        cast(created AS date)                       AS created_date,

        -- last_modified                               AS last_modified_datetime,
        cast(last_modified AS date)                 AS last_modified_date,

        -- auto_cancel_date_current                    AS auto_cancel_date_current_datetime,
        cast(auto_cancel_date_current AS date)      AS auto_cancel_date_current_date,

        -- auto_cancel_date_previous                   AS auto_cancel_date_previous_datetime,
        cast(auto_cancel_date_previous AS date)     AS auto_cancel_date_previous_date,

        -- pause_request_date_current                  AS pause_request_date_current_datetime,
        cast(pause_request_date_current AS date)    AS pause_request_date_current_date,

        -- pause_request_date_previous                 AS pause_request_date_previous_datetime,
        cast(pause_request_date_previous AS date)   AS pause_request_date_previous_date,

        -- pause_effective_date_current                AS pause_effective_date_current_datetime,
        cast(pause_effective_date_current AS date)  AS pause_effective_date_current_date,

        -- pause_effective_date_previous               AS pause_effective_date_previous_datetime,
        cast(pause_effective_date_previous AS date) AS pause_effective_date_previous_date,

        -- pause_end_date_current                      AS pause_end_date_current_datetime,
        cast(pause_end_date_current AS date)        AS pause_end_date_current_date,

        -- pause_end_date_previous                     AS pause_end_date_previous_datetime,
        cast(pause_end_date_previous AS date)       AS pause_end_date_previous_date,

        cancellation_details_reason_current,
        cancellation_details_reason_previous,

        aaa_membership_number_current,
        aaa_membership_number_previous
    FROM source_cte
),

final_cte AS (
    SELECT * FROM renamed_cte
)

SELECT * FROM final_cte
