--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

with source_cte as (
    select
        ID,
        TENANT__R__EXTERNAL_ID__C,
        CREATED,
        LAST_MODIFIED,
        VEHICLE_ID,
        LICENSE_PLATE_NUMBER,
        LICENSE_PLATE_STATE,
        VIF_ID,
        COLOR_ID,
        EVENT_TYPE,
        SUBSCRIPTION_ID,
        PRICE_ID,
        CREATED_BY_ID,
        LAST_MODIFIED_BY_ID
    from {{ source('GENERAL', 'VEHICLE_HISTORY') }}
),

renamed_cte as (
    select
        ID as vehicle_history_id,
        TENANT__R__EXTERNAL_ID__C as tenant_id,

        CREATED as created_datetime,
        cast(CREATED as date) as created_date,

        LAST_MODIFIED as last_modified_datetime,
        cast(LAST_MODIFIED as date) as last_modified_date,

        VEHICLE_ID as vehicle_id,
        LICENSE_PLATE_NUMBER as license_plate_number,
        LICENSE_PLATE_STATE as license_plate_state,
        CONCAT(license_plate_number,',',license_plate_state) AS license_plate_id,
        VIF_ID as vif_id,
        COLOR_ID as color_id,
        EVENT_TYPE as event_type,
        SUBSCRIPTION_ID as subscription_id,
        PRICE_ID as price_id,
        CREATED_BY_ID as created_by_id,
        LAST_MODIFIED_BY_ID as last_modified_by_id
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
