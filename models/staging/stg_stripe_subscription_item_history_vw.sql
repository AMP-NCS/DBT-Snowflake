--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH source_cte AS (
    SELECT
        id,
        tenant__r__external_id__c,
        subscription_id,
        subscription_item_id,
        price_id_previous,
        price_id_current,
        quantity_previous,
        quantity_current,
        tax_rate_previous,
        tax_rate_current,
        created,
        last_modified
    FROM {{ source('REPORTING', 'STRIPE_SUBSCRIPTION_ITEM_HISTORIES') }}
    WHERE ID IS NOT NULL
),

renamed_cte AS (
    SELECT
        id                          AS stripe_subscription_item_history_id,
        tenant__r__external_id__c   AS tenant_id,
        subscription_id,
        subscription_item_id,
        price_id_previous,
        price_id_current,
        quantity_previous,
        quantity_current,
        tax_rate_previous,
        tax_rate_current,

        created                     AS created_datetime,
        cast(created AS date)       AS created_date,

        last_modified               AS last_modified_datetime,
        cast(last_modified AS date) AS last_modified_date
    FROM source_cte
),

final_cte AS (
    SELECT * FROM renamed_cte
)

SELECT * FROM final_cte
