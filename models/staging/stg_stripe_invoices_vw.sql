{{ config(materialized='view') }}

with source_cte as (
    select
        TENANT__R__EXTERNAL_ID__C,
        INVOICE_ID,
        DELETED,
        CUSTOMER_ID,
        PAYMENT_ID,
        SUBSCRIPTION_ID,
        STATUS,
        TOTAL,
        DISCOUNT,
        SUBTOTAL,
        TAX_RATE,
        TAX,
        AMOUNT_PAID,
        AMOUNT_DUE,
        AMOUNT_REMAINING,
        ATTEMPT_COUNT,
        BILLING_REASON,
        POST_PAYMENT_CREDIT_NOTES_AMOUNT,
        PRE_PAYMENT_CREDIT_NOTES_AMOUNT,
        PERIOD_START,
        PERIOD_END,
        INVOICE_CREATED,
        CREATED,
        LAST_MODIFIED,
        HOSTED_INVOICE_URL,
        INVOICE_PDF,
        APP_ID,
        IS_GIFT_CARD,
        TAX_INCLUSIVE,
        LOCATION_ID,
        CREATED_BY_ADMIN_ID,
        KIOSK_ID,
        INVOICE_TYPE,
        PAID_OUT_OF_BAND,
        CHECKOUT_ID,
        WASH_TYPE_ID,
        PREPAID_WASH_PROMOTION_ID,
        PRICE_GROUP_ID,
        PROMO_CODE_ID,
        COUPON_ID,
        PAID_AT,
        MARKED_UNCOLLECTIBLE_AT,
        VOIDED_AT,
        FINALIZED_AT,
        COLLECTION_METHOD,
        AAA_MEMBERSHIP_NUMBER,
        ACCOUNT_ID
    from {{ source('REPORTING','STRIPE_INVOICES') }}
),

renamed_cte as (
    select
        TENANT__R__EXTERNAL_ID__C     as tenant_id,
        INVOICE_ID                    as invoice_id,
        DELETED                        as deleted_flg,
        CUSTOMER_ID                   as stripe_customer_id,
        PAYMENT_ID                    as payment_id,
        SUBSCRIPTION_ID               as subscription_id,
        STATUS                        as status,
        
        TOTAL                         as total_cents,
        TOTAL/100.0                   as total_amt,
        
        DISCOUNT                      as discount_cents,
        DISCOUNT/100.0                as discount_amt,
        
        SUBTOTAL                      as subtotal_cents,
        SUBTOTAL/100.0                as subtotal_amt,
        
        TAX_RATE                      as tax_rate,
        
        TAX                           as tax_cents,
        TAX/100.0                     as tax_amt,
        
        AMOUNT_PAID                   as amount_paid_cents,
        AMOUNT_PAID/100.0             as amount_paid_amt,
        
        AMOUNT_DUE                    as amount_due_cents,
        AMOUNT_DUE/100.0              as amount_due_amt,
        
        AMOUNT_REMAINING              as amount_remaining_cents,
        AMOUNT_REMAINING/100.0        as amount_remaining_amt,
        
        ATTEMPT_COUNT                 as attempt_count,
        BILLING_REASON                as billing_reason,
        
        POST_PAYMENT_CREDIT_NOTES_AMOUNT  as post_payment_credit_notes_cents,
        POST_PAYMENT_CREDIT_NOTES_AMOUNT/100.0 as post_payment_credit_notes_amt,
        
        PRE_PAYMENT_CREDIT_NOTES_AMOUNT   as pre_payment_credit_notes_amount_cents,
        PRE_PAYMENT_CREDIT_NOTES_AMOUNT/100.0 as pre_payment_credit_notes_amt,
        
        PERIOD_START                  as period_start_datetime,
        cast(PERIOD_START as date)    as period_start_date,
        
        PERIOD_END                    as period_end_datetime,
        cast(PERIOD_END as date)      as period_end_date,
        
        INVOICE_CREATED               as invoice_created_datetime,
        cast(INVOICE_CREATED as date) as invoice_created_date,
        
        CREATED                       as created_datetime,
        cast(CREATED as date)         as created_date,
        
        LAST_MODIFIED                 as last_modified_datetime,
        cast(LAST_MODIFIED as date)   as last_modified_date,
        
        HOSTED_INVOICE_URL            as hosted_invoice_url,
        INVOICE_PDF                   as invoice_pdf_url,
        APP_ID                        as app_id,
        
        IS_GIFT_CARD                  as is_gift_card_flg,
        TAX_INCLUSIVE                 as tax_inclusive_flg,
        
        LOCATION_ID                   as location_id,
        CREATED_BY_ADMIN_ID           as created_by_admin_id,
        KIOSK_ID                      as kiosk_id,
        INVOICE_TYPE                  as invoice_type,
        
        PAID_OUT_OF_BAND              as paid_out_of_band_flg,
        
        CHECKOUT_ID                   as checkout_id,
        WASH_TYPE_ID                  as wash_type_id,
        PREPAID_WASH_PROMOTION_ID     as prepaid_wash_promotion_id,
        PRICE_GROUP_ID                as price_group_id,
        PROMO_CODE_ID                 as promo_code_id,
        COUPON_ID                     as coupon_id,
        
        PAID_AT                       as paid_at_datetime,
        cast(PAID_AT as date)         as paid_at_date,
        
        MARKED_UNCOLLECTIBLE_AT       as marked_uncollectible_at_datetime,
        cast(MARKED_UNCOLLECTIBLE_AT as date) as marked_uncollectible_at_date,
        
        VOIDED_AT                     as voided_at_datetime,
        cast(VOIDED_AT as date)       as voided_at_date,
        
        FINALIZED_AT                  as finalized_at_datetime,
        cast(FINALIZED_AT as date)    as finalized_at_date,
        
        COLLECTION_METHOD             as collection_method,
        AAA_MEMBERSHIP_NUMBER         as aaa_membership_number,
        ACCOUNT_ID                    as account_id
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
