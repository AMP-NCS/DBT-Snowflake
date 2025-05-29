--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH source_cte AS (
    SELECT
        tenant__r__external_id__c,
        charge_id,
        amount,
        amount_refunded,
        status,
        failure_code,
        disputed,
        charge_created,
        created,
        last_modified,
        credit_card_fingerprint,
        payment_id,
        invoice_id,
        refunded,
        credit_card_brand,
        credit_card_country,
        credit_card_expiration_month,
        credit_card_expiration_year,
        credit_card_last_four,
        failure_message,
        payment_method_details_card_funding,
        payment_method_details_card_wallet_type,
        payment_method_id
    FROM {{ source('REPORTING', 'STRIPE_CHARGES') }}
),

renamed_cte AS (
    SELECT
        tenant__r__external_id__c    AS tenant_id,
        charge_id,

        amount                       AS amount_cents,
        amount_refunded              AS amount_refunded_cents,

        status,
        failure_code,

        disputed                     AS disputed_flg,
        charge_created               AS charge_created_datetime,

        cast(charge_created AS date) AS charge_created_date,

        created                      AS created_datetime,
        cast(created AS date)        AS created_date,

        last_modified                AS last_modified_datetime,
        cast(last_modified AS date)  AS last_modified_date,

        credit_card_fingerprint,
        payment_id,

        invoice_id,
        refunded                     AS refunded_flg,
        credit_card_brand,

        credit_card_country,

        credit_card_expiration_month,
        credit_card_expiration_year,
        credit_card_last_four,
        failure_message,
        payment_method_details_card_funding,

        payment_method_details_card_wallet_type,
        payment_method_id,
        amount / 100.0               AS amount_amt,
        amount_refunded / 100.0      AS amount_refunded_amt
    FROM source_cte
),

final_cte AS (
    SELECT * FROM renamed_cte
)

SELECT * FROM final_cte
