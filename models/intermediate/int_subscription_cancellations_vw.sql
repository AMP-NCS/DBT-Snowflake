--DBT Model
--2025-05-23 Original model created by Patrick Callahan
--2025-06-17 Updated to a materialized table

{{ config(materialized='view') }}

SELECT
    sc.subscription_id,
    sc.tenant_id,
    sc.cancellation_id,
    sc.subscription_cancellation_external_id,
    sc.created_datetime,
    sc.created_date,
    sc.cancellation_comment,
    sc.cancellation_reason_code,
    sc.picklist_value_id AS cancellation_reason_picklist_id,
    pr.picklist_value    AS cancellation_reason_text,
    sc.cancellation_created_by_user_id,
    sc.is_cancelled_flag,
    sc.autowash_account_id,
    sc.price_id,
    sc.vehicle_id,
    sc.user_id           AS canceled_user_id,
    sc.cancellation_name_code,
    pr.picklist_value_id,
    sh.status_previous   AS status_pre_cancel,
    sc.last_modified_datetime,
    sc.last_modified_date,
    ROW_NUMBER() OVER (PARTITION BY sc.subscription_id ORDER BY sc.created_datetime DESC) AS row_num
    -- CURRENT_TIMESTAMP()  AS table_updated_at
FROM {{ ref('stg_subscription_cancellations_vw') }} AS sc

    -- grab “pre‐cancel” status if they just flipped to canceled
    LEFT OUTER JOIN {{ ref('stg_stripe_subscription_history_vw') }} AS sh
        ON
            sc.subscription_id = sh.subscription_id
            AND sh.status_current = 'canceled'
            AND sh.status_previous <> sh.status_current

    -- bring in your picklist lookup, but only for the “cancellation reason” picklist
    LEFT OUTER JOIN {{ ref('stg_reference_picklist_vw') }} AS pr
        ON
            sc.picklist_value_id = pr.picklist_value_id
            AND pr.picklist_value_id = 1

-- only take the “latest” cancellation per subscription
QUALIFY row_num = 1
