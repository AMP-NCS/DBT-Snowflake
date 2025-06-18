--DBT Model
--2025-05-23 Original model created by Patrick Callahan
--2025-06-16 PC Added a concat for location id and location cd

{{ config(materialized='view') }}

WITH
    base_locations AS (
        SELECT
            loc.external_id__c            AS location_external_id,
            loc.internal_name__c          AS location_internal_name,
            loc.zip_code__c               AS zip_code,
            loc.city__c                   AS city,
            loc.state__c                  AS state,
            loc.street1__c                AS street1,
            loc.street2__c                AS street2,
            loc.location_code,
            loc.tenant__r__external_id__c AS tenant_id
        FROM {{ source('GENERAL','AUTOWASHLOCATION__C') }} AS loc
    ),

    rls_enrichment AS (
        SELECT
            hier.location_id AS location_external_id,
            hier.row_level_security_id,
            hier.is_franchise
        FROM {{ source('INTERNAL','LOCATION_HIERARCHY') }} AS hier
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
    CONCAT(base.tenant_id, '-', base.location_external_id) AS unique_tenant_location_id,
    CONCAT(base.tenant_id, '-', base.location_code)        AS unique_tenant_location_code,

    -- Add franchise flag and row-level security ID
    COALESCE(rls.row_level_security_id, base.tenant_id)    AS row_level_security_id,
    COALESCE(rls.is_franchise, FALSE)                      AS is_franchise_flag,

    -- Categorized RLS ID (used often in TRANSACTIONS_ALL)
    CASE
        WHEN base.tenant_id = '2kds72w63tiujwdmqox8g2q0syvrdqz4' AND COALESCE(rls.is_franchise, FALSE) = TRUE
            THEN '2kds72w63tiujwdmqox8g2q0syvrdqz4_franchise'
        WHEN base.tenant_id = '2kds72w63tiujwdmqox8g2q0syvrdqz4'
            THEN '2kds72w63tiujwdmqox8g2q0syvrdqz4_corporate'
        ELSE COALESCE(rls.row_level_security_id, base.tenant_id)
    END                                                    AS categorized_rls_id

FROM base_locations AS base
    LEFT OUTER JOIN rls_enrichment AS rls
        ON base.location_external_id = rls.location_external_id
