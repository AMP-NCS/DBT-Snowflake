{{ config(materialized='view') }}

with source_cte as (
    select
        ID,
        TENANT__R__EXTERNAL_ID__C,
        CREATED,
        CREATED_BY_ID,
        LAST_MODIFIED,
        LAST_MODIFIED_BY_ID,
        GIFT_CARD_TRANSACTION_ID,
        INVOICE_ID,
        REDEEMED_BY_USER_ID,
        INVOICE_LINE_ITEM_ID,
        REFUND
    from {{ source('GENERAL','GIFT_CARD_TRANSACTION_INVOICE') }}
),

renamed_cte as (
    select
        id                                 as gift_card_transaction_invoice_id,
        tenant__r__external_id__c          as tenant_id,
        created                            as created_datetime,
        to_date(created)                   as created_date,
        created_by_id                      as created_by_user_id,
        last_modified                      as last_modified_datetime,
        to_date(last_modified)             as last_modified_date,
        last_modified_by_id                as last_modified_user_id,
        gift_card_transaction_id           as gift_card_transaction_id,
        invoice_id                         as invoice_id,
        redeemed_by_user_id                as redeemed_by_user_id,
        invoice_line_item_id               as invoice_line_item_id,
        refund                             as refund_flag
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
