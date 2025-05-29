--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

with source_cte as (
    select
        ID,
        TENANT__R__EXTERNAL_ID__C,
        CREATED,
        CREATED_BY_ID,
        LAST_MODIFIED,
        LAST_MODIFIED_BY_ID,
        INTEGRATION_ID,
        VEHICLE_ID,
        RFID
    from {{ source('GENERAL', 'VEHICLE_RFID') }}
),

renamed_cte as (
    select
        ID                            as vehicle_rfid_id,
        TENANT__R__EXTERNAL_ID__C     as tenant_id,
        
        CREATED                       as created_datetime,
        cast(CREATED as date)         as created_date,
        
        CREATED_BY_ID                 as created_by_id,
        
        LAST_MODIFIED                 as last_modified_datetime,
        cast(LAST_MODIFIED as date)   as last_modified_date,
        
        LAST_MODIFIED_BY_ID           as last_modified_by_id,
        INTEGRATION_ID                as integration_id,
        VEHICLE_ID                    as vehicle_id,
        RFID                          as rfid
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
