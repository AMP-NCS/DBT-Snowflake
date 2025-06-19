--DBT Model
--2025-05-23 Original model created by Patrick Callahan
--2025-06-17 Updated to optimize query

{{ config(materialized='view') }}

SELECT
  i.subscription_id,
  c.failure_message                     AS last_charge_failure_message,
  c.failure_code                        AS last_charge_failure_code,
  c.payment_method_details_card_funding AS last_charge_failure_card_funding,
  ROW_NUMBER() OVER (PARTITION BY i.subscription_id ORDER BY c.charge_created_datetime DESC) AS row_num
--   CURRENT_TIMESTAMP()                   AS table_updated_at
FROM {{ ref('stg_stripe_charges_vw') }}      AS c

INNER JOIN {{ ref('stg_stripe_invoices_vw') }}     AS i
  ON c.invoice_id = i.invoice_id

WHERE
  c.failure_message IS NOT NULL
  AND i.subscription_id IS NOT NULL

QUALIFY row_num = 1
