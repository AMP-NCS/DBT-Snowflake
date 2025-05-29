--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

with source_cte as (
    select
        TENANT_ID,
        LICENSE_PLATE_NUMBER
    from {{ source('INTERNAL', 'LEGACY_REACTIVATION_CHECK') }}
),

renamed_cte as (
    select
        TENANT_ID as tenant_id,
        LICENSE_PLATE_NUMBER as license_plate_number
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
