{{ config(materialized='view') }}

WITH
invoices_base AS (
    SELECT *
    FROM {{ ref('stg_stripe_invoices_vw') }}
),

gift_card_redemptions AS (
    SELECT
    redemptions.invoice_id,
    SUM(transactions.gift_card_transaction_amt) * -1 AS total_redemption_amount
    FROM {{ ref('stg_gift_card_transaction_invoice_vw') }} AS redemptions
    INNER JOIN {{ ref('stg_gift_card_transaction_vw') }} AS transactions
    ON redemptions.gift_card_transaction_id = transactions.gift_card_transaction_id
    GROUP BY
    redemptions.invoice_id 
)

SELECT
    i.tenant_id,
    i.invoice_id,
    i.payment_id,
    i.stripe_customer_id AS customer_id,
    i.paid_out_of_band_flag AS paid_out_of_band,
    i.invoice_created_datetime AS invoice_created,
    i.subscription_id,
    i.billing_reason,
    i.status,
    i.tax_rate / 100 AS tax_rate,
    CASE
        WHEN i.status = 'paid' AND i.paid_amt = 0 AND i.paid_out_of_band_flag = TRUE AND i.app_id = 'KIOSK'
        THEN i.total_amt
        ELSE i.total_amt + COALESCE(gcr.total_redemption_amount, 0)
    END AS total_amt,
    i.due_amt AS amount_due,
    i.paid_amt AS amount_paid,
    loc.location_internal_name AS location,
    i.location_id,
    loc.zip_code AS location_zip_code,
    u.email AS attendant,
    u.name AS attendant_name,
    i.app_id,
    i.collection_method,
    i.finalized_at_datetime AS finalized_at,
    i.paid_at_datetime AS paid_at,
    i.marked_uncollectible_at_date AS marked_uncollectible_at,
    i.voided_at_date AS voided_at,
    loc.categorized_rls_id AS row_level_security_id
FROM invoices_base AS i
-- LEFT JOIN locations AS loc
--     ON i.location_id = loc.location_external_id
-- LEFT JOIN users AS u
--     ON i.created_by_admin_user_id = u.user_id
LEFT JOIN gift_card_redemptions AS gcr
    ON i.invoice_id = gcr.invoice_id 