--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
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
        FROM {{ source('GENERAL', 'SUBSCRIPTION_CANCELLATION__C') }}
    ),

    renamed_cte AS (
        SELECT
            id                                                                          AS cancellation_id,
            external_id__c                                                              AS subscription_cancellation_external_id,

            comment__c                                                                  AS cancellation_comment,
            name                                                                        AS cancellation_name_code,

            lastmodifieddate                                                            AS last_modified_datetime,
            cast(lastmodifieddate AS date)                                              AS last_modified_date,

            createddate                                                                 AS created_datetime,
            cast(createddate AS date)                                                   AS created_date,

            stripe_subscription_id__c                                                   AS subscription_id,
            tenant__r__external_id__c                                                   AS tenant_id,
            reason__c                                                                   AS cancellation_reason_code,
            autowash_account__r__external_id__c                                         AS autowash_account_id,
            price_id__c                                                                 AS price_id,
            vehicle_id__c                                                               AS vehicle_id,
            mobile_user__r__external_id__c                                              AS user_id,

            is_cancelled__c                                                             AS is_cancelled_flag,
            created_by_id                                                               AS cancellation_created_by_user_id,
            last_modified_by_id                                                         AS cancellation_last_modified_by_user_id,
            picklist_value_id,
            row_number() OVER (PARTITION BY stripe_subscription_id__c ORDER BY id DESC) AS row_num
        FROM source_cte
    -- qualify row_num = 1
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
