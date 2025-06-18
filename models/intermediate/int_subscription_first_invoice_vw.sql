{{
  config(
    materialized =          'view',
  )
}}

WITH
    ranked_invoices AS (
        SELECT
            subscription_id,
            subtotal_amt,
            discount_amt,
            invoice_created_datetime,
            last_modified_datetime,
            row_number() OVER (
                PARTITION BY subscription_id
                ORDER BY invoice_created_datetime ASC
            ) AS row_num
        FROM {{ ref('stg_stripe_invoices_vw') }}
        WHERE
            status = 'paid'
            AND billing_reason IN ('subscription_create', 'subscription_cycle')
            AND subscription_id IS NOT NULL
        QUALIFY row_num = 1
    )

SELECT
    subscription_id,
    subtotal_amt AS first_invoice_subtotal_amt,
    discount_amt AS first_invoice_discount_amt,
    subtotal_amt - discount_amt AS first_invoice_amt,
    invoice_created_datetime,
    CAST(invoice_created_datetime AS DATE) AS first_invoice_created_date,
    -- last_modified_datetime,
    current_timestamp() AS table_updated_at
FROM ranked_invoices