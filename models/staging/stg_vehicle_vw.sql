--DBT Model
--2025-05-29 Original model created by Patrick Callahan

{{ config(materialized='view') }}

with source_cte as (
    select
        ID,
        TENANT__R__EXTERNAL_ID__C,
        CREATED,
        LAST_MODIFIED,
        ACCOUNT_ID,
        IS_ACTIVE,
        LICENSE_PLATE_NUMBER,
        LICENSE_PLATE_STATE,
        TRANSFER_DATE,
        CANCEL_DATE,
        PRICE_ID,
        VIF_ID,
        COLOR_ID,
        MIGRATION_ID,
        IS_TEMP_TAG,
        SUBSCRIPTION_ID,
        ACTIVE_SUBSCRIPTION_ID,
        SUBSCRIPTION_STATUS,
        INTEGRATION_METADATA,
        CREATED_BY_ID,
        LAST_MODIFIED_BY_ID,
        VIN,
        MODEL_LABEL_OVERRIDE
    from {{ source('GENERAL', 'VEHICLE') }}
),

renamed_cte as (
    select
        ID                             as vehicle_id,
        TENANT__R__EXTERNAL_ID__C      as tenant_id,

        CREATED                        as created_datetime,
        to_date(CREATED)               as created_date,

        LAST_MODIFIED                  as last_modified_datetime,
        to_date(LAST_MODIFIED)         as last_modified_date,

        ACCOUNT_ID                     as account_id,
        IS_ACTIVE                      as is_active_flag,
        LICENSE_PLATE_NUMBER           as license_plate_number,
        LICENSE_PLATE_STATE            as license_plate_state,
        CONCAT(license_plate_number,',',license_plate_state) AS license_plate_id,

        TRANSFER_DATE                  as transfer_datetime,
        to_date(TRANSFER_DATE)         as transfer_date,

        CANCEL_DATE                    as cancel_datetime,
        to_date(CANCEL_DATE)           as cancel_date,

        PRICE_ID                       as price_id,
        VIF_ID                         as vif_id,
        COLOR_ID                       as color_id,
        MIGRATION_ID                   as migration_id,
        IS_TEMP_TAG                    as is_temp_tag_flag,
        SUBSCRIPTION_ID                as subscription_id,
        ACTIVE_SUBSCRIPTION_ID         as active_subscription_id,
        SUBSCRIPTION_STATUS            as subscription_status,
        INTEGRATION_METADATA           as integration_metadata,
        CREATED_BY_ID                  as created_by_user_id,
        LAST_MODIFIED_BY_ID            as last_modified_by_user_id,
        VIN                            as vin,
        MODEL_LABEL_OVERRIDE           as model_label_override
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
