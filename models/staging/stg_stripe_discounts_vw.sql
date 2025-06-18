--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            tenant__r__external_id__c,
            discount_id,
            coupon_id,
            promotion_code_id,
            customer_id,
            subscription_id,
            invoice_id,
            invoice_line_item_id,
            created,
            last_modified,
            deleted,
            id,
            start_date,
            end_date,
            discount_type,
            discount_source_id,
            subscription_item_id
        FROM {{ source('REPORTING', 'STRIPE_DISCOUNTS') }}
    ),

    renamed_cte AS (
        SELECT
            tenant__r__external_id__c   AS tenant_id,
            discount_id,
            coupon_id,
            promotion_code_id,
            customer_id                 AS stripe_customer_id,
            subscription_id,
            invoice_id,
            invoice_line_item_id,

            created                     AS created_datetime,
            cast(created AS date)       AS created_date,

            last_modified               AS last_modified_datetime,
            cast(last_modified AS date) AS last_modified_date,

            deleted                     AS deleted_flag,
            id                          AS stripe_discount_id,

            start_date                  AS start_datetime,
            cast(start_date AS date)    AS start_date,

            end_date                    AS end_datetime,
            cast(end_date AS date)      AS end_date,

            discount_type,
            discount_source_id,
            subscription_item_id
        FROM source_cte
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
