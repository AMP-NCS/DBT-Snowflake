--DBT Model
--2025-05-23 Original model created by Patrick Callahan
--2025-06-17 Updated to a materialized table

{{ config(materialized='view') }}

SELECT
  subscription_id,
  subtotal_amt                    AS first_invoice_subtotal_amt,
  discount_amt                    AS first_invoice_discount_amt,
  subtotal_amt - discount_amt     AS first_invoice_amt,
  invoice_created_datetime,
  CAST(invoice_created_datetime AS DATE) AS first_invoice_created_date,
  ROW_NUMBER() OVER (PARTITION BY subscription_id ORDER BY invoice_created_datetime ASC) AS row_num
--   CURRENT_TIMESTAMP()             AS table_updated_at
FROM {{ ref('stg_stripe_invoices_vw') }}
WHERE
  status = 'paid'
  AND billing_reason IN ('subscription_create','subscription_cycle')
  AND subscription_id IS NOT NULL

QUALIFY row_num = 1
