--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

with source_cte as (
    select
        comment__c,
        name,
        lastmodifieddate,
        external_id__c,
        createddate,
        stripe_subscription_id__c,
        tenant__r__external_id__c,
        reason__c,
        id,
        autowash_account__r__external_id__c,
        price_id__c,
        vehicle_id__c,
        mobile_user__r__external_id__c,
        is_cancelled__c,
        created_by_id,
        last_modified_by_id,
        picklist_value_id
    from {{ source('GENERAL', 'SUBSCRIPTION_CANCELLATION__C') }}
),

renamed_cte as (
    select
        id as subscription_cancellation_id,
        comment__c as comment,
        name,

        lastmodifieddate as last_modified_datetime,
        cast(lastmodifieddate as date) as last_modified_date,

        external_id__c as external_user_id,

        createddate as created_datetime,
        cast(createddate as date) as created_date,

        stripe_subscription_id__c as stripe_subscription_id,
        tenant__r__external_id__c as tenant_id,
        reason__c as reason,
        autowash_account__r__external_id__c as external_account_id,
        price_id__c as price_id,
        vehicle_id__c as vehicle_id,
        mobile_user__r__external_id__c as external_mobile_user_id,

        is_cancelled__c as is_cancelled_flg,
        created_by_id AS cancellation_created_by_customer_id,
        last_modified_by_id,
        picklist_value_id,
        ROW_NUMBER() OVER (PARTITION BY stripe_subscription_id__c ORDER BY id DESC) AS row_num
    from source_cte
),

final_cte as (
    select * from renamed_cte
     WHERE row_num = 1
)

select * from final_cte
