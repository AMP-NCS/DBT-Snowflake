WITH
    stripe_price AS (
        SELECT
            price_id                    AS stripe_price_id,
            product_id                  AS stripe_product_id,
            tenant__r__external_id__c   AS tenant_id,
            deleted                     AS deleted_flg,
            active                      AS active_flg,
            type,
            billing_scheme,
            tax_behavior,
            nickname,
            unit_amount                 AS unit_amount_cents,
            recurring_aggregate_usage,
            recurring_interval,
            recurring_interval_count,
            recurring_usage_type,
            tiers_mode,
            price_created               AS price_created_datetime,
            cast(price_created AS date) AS price_created_date,
            created                     AS created_datetime,
            cast(created AS date)       AS created_date,
            last_modified               AS last_modified_datetime,
            cast(last_modified AS date) AS last_modified_date,
            price_type,
            price_group_id,
            unit_amount / 100           AS unit_amt
        FROM {{ source('REPORTING','STRIPE_PRICES') }}
    ),

    stripe_tiers AS (
        SELECT
            tenant__r__external_id__c                             AS tenant_id,
            price_id                                              AS stripe_price_id,
            max(CASE WHEN tier_id = 1 THEN up_to END)             AS tier1_up_to,
            max(CASE WHEN tier_id = 1 THEN unit_amount / 100 END) AS tier1_amt,
            max(CASE WHEN tier_id = 2 THEN up_to END)             AS tier2_up_to,
            max(CASE WHEN tier_id = 2 THEN unit_amount / 100 END) AS tier2_amt,
            max(CASE WHEN tier_id = 3 THEN up_to END)             AS tier3_up_to,
            max(CASE WHEN tier_id = 3 THEN unit_amount / 100 END) AS tier3_amt,
            max(CASE WHEN tier_id = 4 THEN up_to END)             AS tier4_up_to,
            max(CASE WHEN tier_id = 4 THEN unit_amount / 100 END) AS tier4_amt
        FROM {{ source('REPORTING', 'STRIPE_PRICE_TIERS') }}
        GROUP BY 1, 2
    ),

    stripe_prod AS (
        SELECT
            product_id                    AS stripe_product_id,
            tenant__r__external_id__c     AS tenant_id,
            deleted                       AS deleted_flg,
            active                        AS active_flg,
            name,
            description,
            product_created               AS product_created_datetime,
            cast(product_created AS date) AS product_created_date,
            created                       AS created_datetime,
            cast(created AS date)         AS created_date,
            last_modified                 AS last_modified_datetime,
            cast(last_modified AS date)   AS last_modified_date,
            is_amp                        AS is_amp_flg
        FROM {{ source('REPORTING','STRIPE_PRODUCTS') }}
    ),

    amp_price AS (
        SELECT
            id                                AS amp_product_price_id,
            product_id                        AS amp_product_id,
            stripe_price_id,
            metadata,
            active                            AS active_flg,
            tenant__r__external_id__c         AS tenant_id,
            created_at                        AS created_at_datetime,
            cast(created_at AS date)          AS created_at_date,
            ordinal,
            interval_count,
            interval_type,
            parent_product_price_id,
            last_modified                     AS last_modified_datetime,
            cast(last_modified AS date)       AS last_modified_date,
            parse_json(metadata):PriceGroupId AS price_group_id
        FROM {{ source('STRIPE','PRODUCT_PRICE') }}
    ),

    amp_prod AS (
        SELECT
            stripe_product_id,
            description,
            monthly_limit,
            daily_limit,
            active                      AS active_flg,
            metadata,
            tenant__r__external_id__c   AS tenant_id,
            created_at                  AS created_datetime,
            cast(created_at AS date)    AS created_date,
            id                          AS record_id,
            display_banner              AS display_banner_flg,
            banner_text,
            ordinal,
            app_description,
            name,
            last_modified               AS last_modified_datetime,
            cast(last_modified AS date) AS last_modified_date,
            is_upsell                   AS is_upsell_flg,
            kiosk_image_url
        FROM {{ source('STRIPE','PRODUCT') }}
    ),

    price_group AS (
        SELECT
            id                        AS price_group_id,
            tenant__r__external_id__c AS tenant_id,
            created                   AS created_datetime,
            last_modified             AS last_modified_datetime,
            name,
            description,
            active                    AS active_flg,
            is_taxable                AS is_taxable_flg,
            created_by_id,
            last_modified_by_id,
            date(created)             AS created_date,
            date(last_modified)       AS last_modified_date
        FROM {{ source('GENERAL','PRICE_GROUP') }}
    )


SELECT
    stripe_price.stripe_price_id,
    stripe_price.tenant_id,
    stripe_prod.stripe_product_id,
    amp_price.amp_product_price_id,
    amp_price.amp_product_id,
    stripe_prod.name                 AS product_name,
    stripe_price.nickname            AS produt_detail,
    price_group.name                 AS price_group_name,
    tier1_up_to,

    cast(tier1_amt AS decimal(9, 2)) AS tier1_amt,
    tier2_up_to,

    cast(tier2_amt AS decimal(9, 2)) AS tier2_amt,
    tier3_up_to,

    cast(tier3_amt AS decimal(9, 2)) AS tier3_amt,
    tier4_up_to,

    cast(tier4_amt AS decimal(9, 2)) AS tier4_amt,
    concat(
        stripe_price.recurring_interval_count,
        ' ',
        upper(stripe_price.recurring_interval),
        CASE WHEN stripe_price.recurring_interval_count > 1 THEN 'S' ELSE ''
        END
    )                                AS recurring_inverval

FROM stripe_price

    LEFT OUTER JOIN stripe_tiers
        ON stripe_price.stripe_price_id = stripe_tiers.stripe_price_id

    LEFT OUTER JOIN stripe_prod
        ON stripe_price.stripe_product_id = stripe_prod.stripe_product_id

    LEFT OUTER JOIN amp_price
        ON stripe_price.stripe_price_id = amp_price.stripe_price_id

    LEFT OUTER JOIN amp_prod
        ON stripe_prod.stripe_product_id = amp_prod.stripe_product_id

    LEFT OUTER JOIN price_group
        ON amp_price.price_group_id = price_group.price_group_id



