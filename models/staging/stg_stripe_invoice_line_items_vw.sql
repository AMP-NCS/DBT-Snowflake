{{ config(materialized='view') }}

with source_cte1 as (
    select
        TENANT__R__EXTERNAL_ID__C,
        INVOICE_ID,
        INVOICE_LINE_ITEM_ID,
        PRICE_ID,
        SUBSCRIPTION_ID,
        SUBSCRIPTION_ITEM_ID,
        TYPE,
        DESCRIPTION,
        AMOUNT,
        QUANTITY,
        TAX,
        TAX_RATE,
        PRORATION,
        PERIOD_START,
        PERIOD_END,
        CREATED,
        LAST_MODIFIED,
        DISCOUNT,
        TAX_INCLUSIVE,
        STORED_WASH_SOURCE,
        PROMO_CODE_ID,
        COUPON_ID,
        PRODUCT_CATEGORY,
        PRODUCT_ID
    from {{ source('REPORTING','STRIPE_INVOICE_LINE_ITEMS') }}
)

, source_cte2 AS (
    select
        TENANT_ID,
        INVOICE_LINE_ITEM_ID,
        PRODUCT_ID,
        PRODUCT_CATEGORY
    from {{ source('INTERNAL', 'LINE_ITEM_TO_PRODUCT_ID_MAPPING') }}
)

, source_cte3 AS (
    select
        TENANT__R__EXTERNAL_ID__C,
        CREATED,
        LAST_MODIFIED,
        ID,
        INVOICE_ID,
        INVOICE_LINE_ITEM_ID,
        TAX_RATE_ID
    from {{ source('REPORTING','STRIPE_INVOICE_STRIPE_TAX_RATE') }}
)

, source_cte4 AS (
    select
        INVOICE_ID,
        TAX_RATE_ID,
        ROW_NUMBER() OVER (PARTITION BY INVOICE_ID ORDER BY ID) AS ROW_NUM
    FROM source_cte3
    WHERE TAX_RATE_ID IS NOT NULL
    QUALIFY ROW_NUM = 1
)

, source_cte5 AS (
    SELECT 
        TENANT__R__EXTERNAL_ID__C,
        TAX_RATE_ID,
        DESCRIPTION
    FROM {{ source('REPORTING','STRIPE_TAX_RATES') }}
)

, source_cte6 AS (
    SELECT DISTINCT 
        INVOICE_LINE_ITEM_ID,
        'Gift Card Transaction' AS GIFT_CARD_LINE_ITEM
    FROM {{ source('GENERAL','GIFT_CARD_TRANSACTION_INVOICE') }}
)

, renamed_cte as (
    select
        source_cte1.TENANT__R__EXTERNAL_ID__C            as tenant_id,
        source_cte1.INVOICE_ID                           as invoice_id,
        source_cte1.INVOICE_LINE_ITEM_ID                 as invoice_line_item_id,
        source_cte1.PRICE_ID                             as price_id,
        source_cte1.SUBSCRIPTION_ID                      as subscription_id,
        source_cte1.SUBSCRIPTION_ITEM_ID                 as subscription_item_id,
        source_cte1.TYPE                                 as type,
        source_cte1.DESCRIPTION                          as description,
        source_cte1.AMOUNT                               as invoice_line_item_cents,
        source_cte1.AMOUNT / 100.0                       as invoice_line_item_amt,
        source_cte1.QUANTITY                             as quantity,
        source_cte1.TAX                                  as invoice_line_item_tax_cents,
        source_cte1.TAX / 100.0                          as invoice_line_item_tax_amt,
        source_cte1.TAX_RATE                             as tax_rate,
        source_cte1.PRORATION                            as proration_flg,
        source_cte1.PERIOD_START                         as period_start_datetime,
        to_date(source_cte1.PERIOD_START)                as period_start_date,
        source_cte1.PERIOD_END                           as period_end_datetime,
        to_date(source_cte1.PERIOD_END)                  as period_end_date,
        source_cte1.CREATED                              as created_datetime,
        to_date(source_cte1.CREATED)                     as created_date,
        source_cte1.LAST_MODIFIED                        as last_modified_datetime,
        to_date(source_cte1.LAST_MODIFIED)               as last_modified_date,
        source_cte1.DISCOUNT                             as invoice_line_item_discount_cents,
        source_cte1.DISCOUNT / 100.0                     as invoice_line_item_discount_amt,
        source_cte1.TAX_INCLUSIVE                        as tax_inclusive_flg,
        source_cte1.STORED_WASH_SOURCE                   as stored_wash_source,
        source_cte1.PROMO_CODE_ID                        as promo_code_id,
        source_cte1.COUPON_ID                            as coupon_id,
        COALESCE(source_cte1.PRODUCT_CATEGORY, 
            source_cte2.PRODUCT_CATEGORY)     as product_category,
        COALESCE(source_cte1.PRODUCT_ID, 
            source_cte2.PRODUCT_ID)           as product_id,
        source_cte5.DESCRIPTION              as tax_jurisdiction,
        CASE WHEN source_cte1.QUANTITY > 0 
            AND source_cte6.INVOICE_LINE_ITEM_ID IS NOT NULL
            THEN source_cte6.GIFT_CARD_LINE_ITEM END AS gift_card_line_item
    
    from source_cte1

    LEFT JOIN source_cte2
    ON source_cte1.INVOICE_LINE_ITEM_ID = source_cte2.INVOICE_LINE_ITEM_ID 

    LEFT JOIN source_cte3
    ON source_cte1.INVOICE_LINE_ITEM_ID = source_cte3.INVOICE_LINE_ITEM_ID

    LEFT JOIN source_cte4
    ON source_cte1.INVOICE_ID = source_cte4.INVOICE_ID

    LEFT JOIN source_cte5
    ON COALESCE(source_cte3.TAX_RATE_ID,
                source_cte4.TAX_RATE_ID) = source_cte5.TAX_RATE_ID

    LEFT JOIN source_cte6
    ON source_cte1.INVOICE_LINE_ITEM_ID = source_cte6.INVOICE_LINE_ITEM_ID
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
