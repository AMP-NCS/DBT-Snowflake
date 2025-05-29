{{ config(materialized='view') }}

with source_cte as (
    select
        ID,
        TENANT__R__EXTERNAL_ID__C,
        CREATED,
        CREATED_BY_ID,
        LAST_MODIFIED,
        LAST_MODIFIED_BY_ID,
        GIFT_CARD_ID,
        REQUEST_SOURCE_ID,
        TRANSACTION_TYPE_ID,
        AMOUNT_IN_CENTS,
        USER_ID,
        COMMENT
    from {{ source('GENERAL','GIFT_CARD_TRANSACTION') }}
),

renamed_cte as (
    select
        id                               as gift_card_transaction_id,
        tenant__r__external_id__c        as tenant_id,
        created                          as created_datetime,
        cast(created as date)            as created_date,
        created_by_id                    as created_by_id,
        last_modified                    as last_modified_datetime,
        cast(last_modified as date)      as last_modified_date,
        last_modified_by_id              as last_modified_by_id,
        gift_card_id                     as gift_card_id,
        request_source_id                as request_source_id,
        transaction_type_id              as transaction_type_id,
        amount_in_cents                  as gift_card_transaction_cents,
        amount_in_cents / 100.0          as gift_card_transaction_amt,
        user_id                          as user_id,
        comment                          as comment
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
