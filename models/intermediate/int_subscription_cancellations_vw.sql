--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

-- For each subscription, summarize the most recent cancellation event (if any)
WITH
    latest_cancellation AS (
        SELECT
            stripe_subscription_id              AS subscription_id,
            tenant_id,
            subscription_cancellation_id,
            created_datetime                    AS cancellation_created_datetime,
            created_date                        AS cancellation_created_date,
            last_modified_datetime              AS cancellation_last_modified_datetime,
            last_modified_date                  AS cancellation_last_modified_date,
            comment                             AS cancellation_comment,
            reason                              AS cancellation_reason,
            picklist_value_id                   AS cancellation_reason_picklist_id,
            cancellation_created_by_customer_id AS canceled_by_user_id,
            is_cancelled_flg,
            external_account_id                 AS account_id,
            price_id,
            vehicle_id,
            external_mobile_user_id             AS mobile_user_id,
            name                                AS cancellation_name
        FROM {{ ref('stg_subscription_cancellations_vw') }}
        WHERE row_num = 1
    ),

    reason_lookup AS (
        SELECT
            picklist_value_id,
            value AS cancellation_reason_text,
            key   AS cancellation_reason_code
        FROM {{ ref('stg_reference_picklist_vw') }}
        WHERE picklist_id = 1 -- cancellation reason picklist
    ),

    status_pre_canc AS (
        SELECT
            subscription_id,
            status_previous
        FROM {{ ref('stg_stripe_subscription_history_vw') }}
        WHERE status_current = 'canceled' AND status_previous <> status_current
    ),

    last_charge_failure AS (
        SELECT
            i.subscription_id,
            c.failure_message,
            c.failure_code,
            c.payment_method_details_card_funding,
            row_number() OVER (PARTITION BY i.subscription_id ORDER BY c.charge_created_datetime DESC) AS row_num
        FROM {{ ref('stg_stripe_charges_vw') }} AS c
            INNER JOIN {{ ref('stg_stripe_invoices_vw') }} AS i ON c.invoice_id = i.invoice_id
        WHERE c.failure_message IS NOT NULL AND i.subscription_id IS NOT NULL
        QUALIFY row_num = 1
    )

SELECT
    lc.subscription_id,
    lc.tenant_id,
    lc.subscription_cancellation_id,
    -- lc.cancellation_created_datetime,
    lc.cancellation_created_date,
    -- lc.cancellation_last_modified_datetime,
    lc.cancellation_last_modified_date,
    lc.cancellation_comment,
    lc.cancellation_reason,
    rl.cancellation_reason_code,
    rl.cancellation_reason_text,
    lc.canceled_by_user_id,
    lc.is_cancelled_flg,
    lc.account_id,
    lc.price_id,
    lc.vehicle_id,
    lc.mobile_user_id,
    lc.cancellation_name,
    spc.status_previous                     AS status_pre_cancel,
    lcf.failure_message                     AS last_charge_failure_message,
    lcf.failure_code                        AS last_charge_failure_code,
    lcf.payment_method_details_card_funding AS last_charge_failure_card_funding
FROM latest_cancellation AS lc
    LEFT OUTER JOIN reason_lookup AS rl
        ON lc.cancellation_reason_picklist_id = rl.picklist_value_id
    LEFT OUTER JOIN status_pre_canc AS spc
        ON lc.subscription_id = spc.subscription_id
    LEFT OUTER JOIN last_charge_failure AS lcf
        ON lc.subscription_id = lcf.subscription_id