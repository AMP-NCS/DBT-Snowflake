--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            tenant_id,
            license_plate_number
        FROM {{ source('INTERNAL', 'LEGACY_REACTIVATION_CHECK') }}
    ),

    renamed_cte AS (
        SELECT
            tenant_id,
            license_plate_number
        FROM source_cte
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
