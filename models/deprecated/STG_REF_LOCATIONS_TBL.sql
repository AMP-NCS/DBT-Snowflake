{{ config(
    materialized='incremental',
    unique_key='LOCATION_ID',
    on_schema_change='sync_all_columns',
    persist_docs={"relation": true, "columns": true}
) }}

WITH source_cte1 AS (
    SELECT *
    FROM {{source('GENERAL','AUTOWASHLOCATION__C')}}
)

, source_cte2 AS (
    SELECT *
    FROM {{source('INTERNAL','LOCATION_HIERARCHY')}}
)

, renamed AS (
SELECT loc.EXTERNAL_ID__C AS LOCATION_ID,
       loc.TENANT__R__EXTERNAL_ID__C AS TENANT_ID,
       loc.NAME AS LOCATION_NAME,
       loc.INTERNAL_NAME__C AS LOCATION_INTERNAL_NAME,
       hier.IS_FRANCHISE AS LOCATION_IS_FRANCHISE,
       hier.IS_TEST_LOCATION AS TEST_LOCATION,
       loc.LOCATION_CODE AS LOCATION_CODE,
       loc.STREET1__C AS LOCATION_STREET1,
       loc.STREET2__C AS LOCATION_STREET2,
       loc.CITY__C AS LOCATION_CITY,
       loc.STATE__C AS LOCATION_STATE,
       loc.ZIP_CODE__C AS LOCATION_ZIP_CODE,
       loc.IMAGE_URL__C AS LOCATION_IMAGE_URL,
       loc.CREATEDDATE AS LOCATION_CREATED_DATETIME,
       loc.LASTMODIFIEDDATE AS LAST_MODIFIED_DATETIME,
       CASE
           WHEN loc.TENANT__R__EXTERNAL_ID__C = '2kds72w63tiujwdmqox8g2q0syvrdqz4'
               AND hier.IS_FRANCHISE = TRUE
               THEN '2kds72w63tiujwdmqox8g2q0syvrdqz4_franchise'
           WHEN loc.TENANT__R__EXTERNAL_ID__C = '2kds72w63tiujwdmqox8g2q0syvrdqz4'
               THEN '2kds72w63tiujwdmqox8g2q0syvrdqz4_corporate'
           ELSE COALESCE(hier.ROW_LEVEL_SECURITY_ID, loc.TENANT__R__EXTERNAL_ID__C)
           END AS ROW_LEVEL_SECURITY_ID
FROM source_cte1 loc
         LEFT JOIN source_cte2 hier
                   ON loc.EXTERNAL_ID__C = hier.LOCATION_ID
)


SELECT *
FROM renamed
{% if is_incremental() %}
WHERE LAST_MODIFIED_DATETIME > (SELECT MAX(LAST_MODIFIED_DATETIME) FROM {{ this }})
{% endif %}