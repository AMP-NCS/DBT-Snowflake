
{{
  config(
    materialized='view'
  )
}}

select 
    subscription_id, 
    SUM(1) as number_of_paid_invoices_to_date
from {{ ref('stg_stripe_invoices_vw') }}
where subscription_id IS NOT NULL
  and status = 'paid'
  and billing_reason in ('subscription_create','subscription_cycle')
group by 1