WITH stripe_price as (
    select
        PRICE_ID                                      as stripe_price_id,
        PRODUCT_ID                                    as stripe_product_id,       
        TENANT__R__EXTERNAL_ID__C                     as tenant_id,
        DELETED                                        as deleted_flg,
        ACTIVE                                         as active_flg,
        TYPE                                           as type,
        BILLING_SCHEME                                 as billing_scheme,
        TAX_BEHAVIOR                                   as tax_behavior,
        NICKNAME                                       as nickname,
        UNIT_AMOUNT                                    as unit_amount_cents,
        UNIT_AMOUNT/100                                as unit_amt,
        RECURRING_AGGREGATE_USAGE                      as recurring_aggregate_usage,
        RECURRING_INTERVAL                             as recurring_interval,
        RECURRING_INTERVAL_COUNT                       as recurring_interval_count,
        RECURRING_USAGE_TYPE                           as recurring_usage_type,
        TIERS_MODE                                     as tiers_mode,
        PRICE_CREATED                                  as price_created_datetime,
        cast(PRICE_CREATED as date)                    as price_created_date,
        CREATED                                        as created_datetime,
        cast(CREATED as date)                          as created_date,
        LAST_MODIFIED                                  as last_modified_datetime,
        cast(LAST_MODIFIED as date)                    as last_modified_date,
        PRICE_TYPE                                     as price_type,
        PRICE_GROUP_ID                                 as price_group_id
    from {{ source('REPORTING','STRIPE_PRICES') }}
)

, stripe_tiers as (
    select
        TENANT__R__EXTERNAL_ID__C as tenant_id,
        PRICE_ID as stripe_price_id,
        MAX(CASE WHEN TIER_ID = 1 THEN UP_TO END)           AS TIER1_UP_TO,
        MAX(CASE WHEN TIER_ID = 1 THEN UNIT_AMOUNT/100 END) AS TIER1_AMT,
        MAX(CASE WHEN TIER_ID = 2 THEN UP_TO END)           AS TIER2_UP_TO,
        MAX(CASE WHEN TIER_ID = 2 THEN UNIT_AMOUNT/100 END) AS TIER2_AMT,
        MAX(CASE WHEN TIER_ID = 3 THEN UP_TO END)           AS TIER3_UP_TO,
        MAX(CASE WHEN TIER_ID = 3 THEN UNIT_AMOUNT/100 END) AS TIER3_AMT,
        MAX(CASE WHEN TIER_ID = 4 THEN UP_TO END)           AS TIER4_UP_TO,
        MAX(CASE WHEN TIER_ID = 4 THEN UNIT_AMOUNT/100 END) AS TIER4_AMT
    from {{ source('REPORTING', 'STRIPE_PRICE_TIERS') }}
    GROUP BY 1,2
)

, stripe_prod as (
    select
        PRODUCT_ID                                     as stripe_product_id,
        TENANT__R__EXTERNAL_ID__C                      as tenant_id,
        DELETED                                         as deleted_flg,
        ACTIVE                                          as active_flg,
        NAME                                            as name,
        DESCRIPTION                                     as description,
        PRODUCT_CREATED                                 as product_created_datetime,
        cast(PRODUCT_CREATED as date)                   as product_created_date,
        CREATED                                         as created_datetime,
        cast(CREATED as date)                           as created_date,
        LAST_MODIFIED                                   as last_modified_datetime,
        cast(LAST_MODIFIED as date)                     as last_modified_date,
        IS_AMP                                          as is_amp_flg
    from {{ source('REPORTING','STRIPE_PRODUCTS') }}
)

, amp_price as (
    select
        ID                                  as amp_product_price_id,
        PRODUCT_ID                          as amp_product_id,
        STRIPE_PRICE_ID                     as stripe_price_id,
        METADATA                            as metadata,
        PARSE_JSON(METADATA):PriceGroupId   as price_group_id,
        ACTIVE                              as active_flg,
        TENANT__R__EXTERNAL_ID__C           as tenant_id,
        CREATED_AT                          as created_at_datetime,
        cast(CREATED_AT as date)            as created_at_date,
        ORDINAL                             as ordinal,
        INTERVAL_COUNT                      as interval_count,
        INTERVAL_TYPE                       as interval_type,
        PARENT_PRODUCT_PRICE_ID             as parent_product_price_id,
        LAST_MODIFIED                       as last_modified_datetime,
        cast(LAST_MODIFIED as date)         as last_modified_date
    from {{ source('STRIPE','PRODUCT_PRICE') }}
)

, amp_prod as (
    select
        stripe_product_id                  as stripe_product_id,
        description                        as description,
        monthly_limit                      as monthly_limit,
        daily_limit                        as daily_limit,
        active                             as active_flg,
        metadata                           as metadata,
        TENANT__R__EXTERNAL_ID__C          as tenant_id,
        CREATED_AT                         as created_datetime,
        cast(CREATED_AT as date)           as created_date,
        ID                                 as record_id,
        DISPLAY_BANNER                     as display_banner_flg,
        banner_text                        as banner_text,
        ordinal                            as ordinal,
        app_description                    as app_description,
        name                               as name,
        LAST_MODIFIED                      as last_modified_datetime,
        cast(LAST_MODIFIED as date)        as last_modified_date,
        IS_UPSELL                          as is_upsell_flg,
        kiosk_image_url                    as kiosk_image_url
    from {{ source('STRIPE','PRODUCT') }}
)

, price_group as (
    select
        ID                                         as price_group_id,
        TENANT__R__EXTERNAL_ID__C                  as tenant_id,
        CREATED                                    as created_datetime,
        date(CREATED)                              as created_date,
        LAST_MODIFIED                              as last_modified_datetime,
        date(LAST_MODIFIED)                        as last_modified_date,
        NAME                                       as name,
        DESCRIPTION                                as description,
        ACTIVE                                     as active_flg,
        IS_TAXABLE                                 as is_taxable_flg,
        CREATED_BY_ID                              as created_by_id,
        LAST_MODIFIED_BY_ID                        as last_modified_by_id
    from {{ source('GENERAL','PRICE_GROUP') }}
)


SELECT stripe_price.STRIPE_PRICE_ID,
       stripe_price.TENANT_ID,
       stripe_prod.STRIPE_PRODUCT_ID,
       amp_price.AMP_PRODUCT_PRICE_ID,
       amp_price.AMP_PRODUCT_ID,
       stripe_prod.NAME AS PRODUCT_NAME,
       stripe_price.NICKNAME AS PRODUT_DETAIL,
       price_group.NAME AS PRICE_GROUP_NAME,
       CONCAT(stripe_price.RECURRING_INTERVAL_COUNT
                ,' '
                ,UPPER(stripe_price.RECURRING_INTERVAL)
                , CASE WHEN stripe_price.RECURRING_INTERVAL_COUNT > 1 THEN 'S' ELSE ''
                END) AS RECURRING_INVERVAL,
       
       TIER1_UP_TO,
       CAST(TIER1_AMT AS DECIMAL(9,2)) AS TIER1_AMT,

       TIER2_UP_TO,
       CAST(TIER2_AMT AS DECIMAL(9,2)) AS TIER2_AMT,

       TIER3_UP_TO,
       CAST(TIER3_AMT AS DECIMAL(9,2)) AS TIER3_AMT,

       TIER4_UP_TO,
       CAST(TIER4_AMT AS DECIMAL(9,2)) AS TIER4_AMT

FROM stripe_price

    LEFT JOIN stripe_tiers  
        ON stripe_price.stripe_price_id = stripe_tiers.stripe_price_id
    
    LEFT JOIN stripe_prod
        ON stripe_price.STRIPE_PRODUCT_ID = stripe_prod.STRIPE_PRODUCT_ID

    LEFT JOIN amp_price
        ON stripe_price.STRIPE_PRICE_ID = amp_price.STRIPE_PRICE_ID
        
    LEFT JOIN amp_prod
        ON amp_prod.STRIPE_PRODUCT_ID = stripe_prod.STRIPE_PRODUCT_ID

    LEFT JOIN price_group
        ON price_group.PRICE_GROUP_ID = amp_price.PRICE_GROUP_ID



