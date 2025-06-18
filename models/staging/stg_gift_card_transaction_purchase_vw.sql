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
        IS_GUEST_PURCHASE,
        PURCHASED_BY_USER_ID,
        PURCHASED_BY_GUEST_NAME,
        PURCHASED_BY_GUEST_EMAIL,
        GIFT_CARD_PROMOTION_ID
    from {{ source('GENERAL', 'GIFT_CARD_TRANSACTION_PURCHASE') }}
),

renamed_cte as (
    select
        ID                            as gift_card_transaction_purchase_id,
        TENANT__R__EXTERNAL_ID__C     as tenant_id,
        CREATED                       as created_datetime,
        cast(CREATED as date)         as created_date,
        CREATED_BY_ID                 as created_by_user_id,
        LAST_MODIFIED                 as last_modified_datetime,
        cast(LAST_MODIFIED as date)   as last_modified_date,
        LAST_MODIFIED_BY_ID           as last_modified_by_user_id,
        GIFT_CARD_TRANSACTION_ID      as gift_card_transaction_id,
        INVOICE_ID                    as invoice_id,
        IS_GUEST_PURCHASE             as is_guest_purchase_flag,
        PURCHASED_BY_USER_ID          as purchased_by_user_id,
        PURCHASED_BY_GUEST_NAME       as purchased_by_guest_name,
        PURCHASED_BY_GUEST_EMAIL      as purchased_by_guest_email,
        GIFT_CARD_PROMOTION_ID        as gift_card_promotion_id
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
