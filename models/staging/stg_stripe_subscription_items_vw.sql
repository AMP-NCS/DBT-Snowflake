{{ config(materialized='view') }}

WITH source_cte AS (
    SELECT
        tenant__r__external_id__c,
        subscription_id,
        subscription_item_id,
        price_id,
        quantity,
        created,
        last_modified
        -- Add any other columns from the source as needed
    FROM {{ source('REPORTING', 'STRIPE_SUBSCRIPTION_ITEMS') }}
)

SELECT
    tenant__r__external_id__c   AS tenant_id,
    subscription_id,
    subscription_item_id,
    price_id,
    quantity,
    created                     AS created_datetime,
    CAST(created AS date)       AS created_date,
    last_modified               AS last_modified_datetime,
    CAST(last_modified AS date) AS last_modified_date
    -- Add any other columns with snake_case aliases as needed
FROM source_cte