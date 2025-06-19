{{ config(materialized='view') }}

SELECT
    redemptions.invoice_id,
    SUM(transactions.amount_in_cents) / -100 AS total_redemption_amount
FROM {{ ref('stg_gift_card_transaction_invoice_vw') }} AS redemptions
INNER JOIN {{ ref('stg_gift_card_transaction_vw') }} AS transactions
    ON redemptions.gift_card_transaction_id = transactions.id
GROUP BY
    redemptions.invoice_id 