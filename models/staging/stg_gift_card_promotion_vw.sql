{{ config(materialized='view') }}

with source_cte as (
    select
        ID,
        TENANT__R__EXTERNAL_ID__C,
        CREATED,
        CREATED_BY_ID,
        LAST_MODIFIED,
        LAST_MODIFIED_BY_ID,
        NAME,
        PURCHASE_PRICE_CENTS,
        VALUE_CENTS,
        PROMOTION_TILE_IMAGE_URL,
        ACTIVE,
        EFFECTIVE_FROM,
        EFFECTIVE_TO,
        MARKETING_LABEL,
        ORDINAL
    from {{ source('GENERAL','GIFT_CARD_PROMOTION') }}
),

renamed_cte as (
    select
        ID                                     as promotion_id,
        TENANT__R__EXTERNAL_ID__C              as tenant_id,
        CREATED                                 as created_datetime,
        to_date(CREATED)                        as created_date,
        CREATED_BY_ID                           as created_by_id,
        LAST_MODIFIED                           as last_modified_datetime,
        to_date(LAST_MODIFIED)                  as last_modified_date,
        LAST_MODIFIED_BY_ID                     as last_modified_by_id,
        NAME                                    as name,
        PURCHASE_PRICE_CENTS                    as purchase_price_cents,
        PURCHASE_PRICE_CENTS/100.0              as purchase_price_amt,
        VALUE_CENTS                             as value_cents,
        VALUE_CENTS/100.0                       as value_amt,
        PROMOTION_TILE_IMAGE_URL                as promotion_tile_image_url,
        ACTIVE                                  as active_flg,
        EFFECTIVE_FROM                          as effective_from_datetime,
        to_date(EFFECTIVE_FROM)                 as effective_from_date,
        EFFECTIVE_TO                            as effective_to_datetime,
        to_date(EFFECTIVE_TO)                   as effective_to_date,
        MARKETING_LABEL                         as marketing_label,
        ORDINAL                                 as ordinal
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
