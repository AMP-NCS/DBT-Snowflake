--DBT Model
--2025-06-17 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            id,
            tenant__r__external_id__c,
            picklist_id,
            key,
            value,
            active,
            ordinal,
            created,
            last_modified,
            created_by_id,
            last_modified_by_id
        FROM {{ source('GENERAL','PICKLIST_VALUE') }}
    ),

    renamed_cte AS (
        SELECT
            id                        AS picklist_value_id,
            tenant__r__external_id__c AS tenant_id,
            picklist_id,
            key                       AS picklist_key,
            value                     AS picklist_value,
            active                    AS active_flag,
            ordinal,
            -- created                   AS created_datetime,
            -- last_modified             AS last_modified_datetime,
            created_by_id             AS created_by_user_id,
            last_modified_by_id       AS last_modified_by_user_id,
            to_date(created)          AS created_date,
            to_date(last_modified)    AS last_modified_date
        FROM source_cte
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
