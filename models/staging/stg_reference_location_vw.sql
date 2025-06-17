--DBT Model
--2025-05-23 Original model created by Patrick Callahan
--2025-06-16 PC Added a concat for location id and location cd

{{ config(materialized='view') }}

WITH base_locations AS (
    SELECT
        loc.EXTERNAL_ID__C AS location_external_id,
        loc.INTERNAL_NAME__C AS location_internal_name,
        loc.ZIP_CODE__C AS zip_code,
        loc.CITY__C AS city,
        loc.STATE__C AS state,
        loc.STREET1__C AS street1,
        loc.STREET2__C AS street2,
        loc.LOCATION_CODE AS location_code,
        loc.TENANT__R__EXTERNAL_ID__C AS tenant_id
    FROM {{ source('GENERAL','AUTOWASHLOCATION__C') }} loc
),

rls_enrichment AS (
    SELECT
        hier.LOCATION_ID AS location_external_id,
        hier.ROW_LEVEL_SECURITY_ID,
        hier.IS_FRANCHISE
    FROM {{ source('INTERNAL','LOCATION_HIERARCHY') }} hier
)

SELECT
    base.location_external_id,
    base.location_internal_name,
    base.zip_code,
    base.city,
    base.state,
    base.street1,
    base.street2,
    base.location_code,
    base.tenant_id,
    CONCAT(base.tenant_id,'-',base.location_external_id) AS unique_tenant_location_id,
    CONCAT(base.tenant_id,'-',base.location_code) AS unique_tenant_location_code,

    -- Add franchise flag and row-level security ID
    COALESCE(rls.ROW_LEVEL_SECURITY_ID, base.tenant_id) AS row_level_security_id,
    COALESCE(rls.IS_FRANCHISE, FALSE) AS is_franchise,

    -- Categorized RLS ID (used often in TRANSACTIONS_ALL)
    CASE
        WHEN base.tenant_id = '2kds72w63tiujwdmqox8g2q0syvrdqz4' AND COALESCE(rls.IS_FRANCHISE, FALSE) = TRUE
            THEN '2kds72w63tiujwdmqox8g2q0syvrdqz4_franchise'
        WHEN base.tenant_id = '2kds72w63tiujwdmqox8g2q0syvrdqz4'
            THEN '2kds72w63tiujwdmqox8g2q0syvrdqz4_corporate'
        ELSE COALESCE(rls.ROW_LEVEL_SECURITY_ID, base.tenant_id)
    END AS categorized_rls_id

FROM base_locations base
LEFT JOIN rls_enrichment rls
    ON base.location_external_id = rls.location_external_id
