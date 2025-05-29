{{ config(materialized='view') }}

with source_cte as (
    select
        STRIPE_SUBSCRIPTION_STATUS__C,
        NAME,
        LASTMODIFIEDDATE,
        EXTERNAL_ID__C,
        CREATEDDATE,
        STRIPE_SUBSCRIPTION_ID__C,
        ID,
        PRIMARY_ACCOUNT_HOLDER__R__EXTERNAL_ID__C,
        TENANT__R__EXTERNAL_ID__C,
        ALLOW_PAY_PER_WASH__C,
        ACCOUNT_TYPE__C,
        PAY_PER_WASH_COLLECTION_METHOD__C,
        ACCOUNT_APPROACH__C,
        PRICE_SYNC_REQUEST_TIME,
        CREATED_BY_ID,
        LAST_MODIFIED_BY_ID,
        CANCEL_DATE,
        ACTION_START_TIME,
        IS_DELETED,
        PRORATE_SUBSCRIPTION_CHANGES
    from {{ source('GENERAL', 'AUTOWASH_ACCOUNT__C') }}
),

renamed_cte as (
    select
        stripe_subscription_status__c          as stripe_subscription_status,
        name                                   as name,
        lastmodifieddate                       as lastmodified_datetime,
        cast(lastmodifieddate as date)         as lastmodified_date,
        external_id__c                         as external_id,
        createddate                            as created_datetime,
        cast(createddate as date)              as created_date,
        stripe_subscription_id__c              as stripe_subscription_id,
        id                                      as autowash_account_id,
        primary_account_holder__r__external_id__c as primary_account_holder_id,
        tenant__r__external_id__c              as tenant_id,
        allow_pay_per_wash__c                  as allow_pay_per_wash_flg,
        account_type__c                        as account_type,
        pay_per_wash_collection_method__c      as pay_per_wash_collection_method,
        account_approach__c                    as account_approach,
        price_sync_request_time                as price_sync_request_datetime,
        cast(price_sync_request_time as date)  as price_sync_request_date,
        created_by_id                          as created_by_id,
        last_modified_by_id                    as last_modified_by_id,
        cancel_date                            as cancel_datetime,
        cast(cancel_date as date)              as cancel_date,
        action_start_time                      as action_start_datetime,
        cast(action_start_time as date)        as action_start_date,
        is_deleted                             as is_deleted_flg,
        prorate_subscription_changes           as prorate_subscription_changes_flg
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
