{{ config(materialized='view') }}

WITH
    source_cte1 AS (
        SELECT
            tenant__r__external_id__c,
            invoice_id,
            invoice_line_item_id,
            price_id,
            subscription_id,
            subscription_item_id,
            type,
            description,
            amount,
            quantity,
            tax,
            tax_rate,
            proration,
            period_start,
            period_end,
            created,
            last_modified,
            discount,
            tax_inclusive,
            stored_wash_source,
            promo_code_id,
            coupon_id,
            product_category,
            product_id
        FROM {{ source('REPORTING','STRIPE_INVOICE_LINE_ITEMS') }}
    ),

    source_cte2 AS (
        SELECT
            tenant_id,
            invoice_line_item_id,
            product_id,
            product_category
        FROM {{ source('INTERNAL', 'LINE_ITEM_TO_PRODUCT_ID_MAPPING') }}
    ),

    source_cte3 AS (
        SELECT
            tenant__r__external_id__c,
            created,
            last_modified,
            id,
            invoice_id,
            invoice_line_item_id,
            tax_rate_id
        FROM {{ source('REPORTING','STRIPE_INVOICE_STRIPE_TAX_RATE') }}
    ),

    source_cte4 AS (
        SELECT
            invoice_id,
            tax_rate_id,
            ROW_NUMBER() OVER (PARTITION BY invoice_id ORDER BY id) AS row_num
        FROM source_cte3
        WHERE tax_rate_id IS NOT NULL
        QUALIFY row_num = 1
    ),

    source_cte5 AS (
        SELECT
            tenant__r__external_id__c,
            tax_rate_id,
            description
        FROM {{ source('REPORTING','STRIPE_TAX_RATES') }}
    ),

    source_cte6 AS (
        SELECT DISTINCT
            invoice_line_item_id,
            'Gift Card Transaction' AS gift_card_line_item
        FROM {{ source('GENERAL','GIFT_CARD_TRANSACTION_INVOICE') }}
    ),

    renamed_cte AS (
        SELECT
            source_cte1.tenant__r__external_id__c AS tenant_id,
            source_cte1.invoice_id,
            source_cte1.invoice_line_item_id,
            source_cte1.price_id,
            source_cte1.subscription_id,
            source_cte1.subscription_item_id,
            source_cte1.type,
            source_cte1.description,
            -- source_cte1.amount                    AS invoice_line_item_cents,
            source_cte1.amount / 100.0            AS invoice_line_item_amt,
            source_cte1.quantity,
            -- source_cte1.tax                       AS invoice_line_item_tax_cents,
            source_cte1.tax / 100.0               AS invoice_line_item_tax_amt,
            source_cte1.tax_rate,
            source_cte1.proration                 AS proration_flag,
            source_cte1.period_start              AS period_start_datetime,
            TO_DATE(source_cte1.period_start)     AS period_start_date,
            source_cte1.period_end                AS period_end_datetime,
            TO_DATE(source_cte1.period_end)       AS period_end_date,
            source_cte1.created                   AS created_datetime,
            TO_DATE(source_cte1.created)          AS created_date,
            source_cte1.last_modified             AS last_modified_datetime,
            TO_DATE(source_cte1.last_modified)    AS last_modified_date,
            -- source_cte1.discount                  AS invoice_line_item_discount_cents,
            source_cte1.discount / 100.0          AS invoice_line_item_discount_amt,
            source_cte1.tax_inclusive             AS tax_inclusive_flag,
            source_cte1.stored_wash_source,
            source_cte1.promo_code_id,
            source_cte1.coupon_id,
            source_cte5.description               AS tax_jurisdiction,
            COALESCE(
                source_cte1.product_category,
                source_cte2.product_category
            )                                     AS product_category,
            COALESCE(
                source_cte1.product_id,
                source_cte2.product_id
            )                                     AS product_id,
            CASE
                WHEN
                    source_cte1.quantity > 0
                    AND source_cte6.invoice_line_item_id IS NOT NULL
                    THEN source_cte6.gift_card_line_item
            END                                   AS gift_card_line_item

        FROM source_cte1

            LEFT OUTER JOIN source_cte2
                ON source_cte1.invoice_line_item_id = source_cte2.invoice_line_item_id

            LEFT OUTER JOIN source_cte3
                ON source_cte1.invoice_line_item_id = source_cte3.invoice_line_item_id

            LEFT OUTER JOIN source_cte4
                ON source_cte1.invoice_id = source_cte4.invoice_id

            LEFT OUTER JOIN source_cte5
                ON COALESCE(
                    source_cte3.tax_rate_id,
                    source_cte4.tax_rate_id
                ) = source_cte5.tax_rate_id

            LEFT OUTER JOIN source_cte6
                ON source_cte1.invoice_line_item_id = source_cte6.invoice_line_item_id
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
