--DBT Model
--2025-05-23 Original model created by Patrick Callahan
--2025-06-17 Updated to a materialized table

{{
  config(
    materialized='view'
  )
}}

-- For each subscription, summarize the most recent cancellation event (if any)
WITH
    latest_cancellation AS (
        SELECT
            subscription_id,
            tenant_id,
            cancellation_id,
            subscription_cancellation_external_id,
            created_datetime,
            created_date,
            last_modified_datetime,
            last_modified_date,
            cancellation_comment,
            cancellation_reason_code,
            picklist_value_id                   AS cancellation_reason_picklist_id,
            cancellation_created_by_user_id,
            is_cancelled_flag,
            autowash_account_id,
            price_id,
            vehicle_id,
            user_id,
            cancellation_name_code
        FROM {{ ref('stg_subscription_cancellations_vw') }}
        WHERE row_num = 1
    ),

    reason_lookup AS (
        SELECT
            picklist_value_id,
            picklist_value AS cancellation_reason_text,
            picklist_key   AS cancellation_reason_code
        FROM {{ ref('stg_reference_picklist_vw') }}
        WHERE picklist_value_id = 1 -- cancellation reason picklist
    ),

    status_pre_canc AS (
        SELECT
            subscription_id,
            status_previous
        FROM {{ ref('stg_stripe_subscription_history_vw') }}
        WHERE status_current = 'canceled' AND status_previous <> status_current
    )

SELECT
    lc.subscription_id,
    lc.tenant_id,
    lc.cancellation_id,
    lc.subscription_cancellation_external_id,
    lc.created_datetime,
    lc.created_date,
    lc.cancellation_comment,
    lc.cancellation_reason_code,
    lc.cancellation_reason_picklist_id,
    rl.cancellation_reason_text,
    lc.cancellation_created_by_user_id,
    lc.is_cancelled_flag,
    lc.autowash_account_id,
    lc.price_id,
    lc.vehicle_id,
    lc.user_id                              AS canceled_user_id,
    lc.cancellation_name_code,
    rl.picklist_value_id,
    spc.status_previous                     AS status_pre_cancel,
    lc.last_modified_datetime,
    lc.last_modified_date,
    current_timestamp()                     AS table_updated_at
FROM latest_cancellation AS lc
    LEFT OUTER JOIN reason_lookup AS rl
        ON lc.cancellation_reason_picklist_id = rl.picklist_value_id
    LEFT OUTER JOIN status_pre_canc AS spc
        ON lc.subscription_id = spc.subscription_id