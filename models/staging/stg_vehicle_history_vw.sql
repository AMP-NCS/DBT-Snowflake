--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            id,
            tenant__r__external_id__c,
            created,
            last_modified,
            vehicle_id,
            license_plate_number,
            license_plate_state,
            vif_id,
            color_id,
            event_type,
            subscription_id,
            price_id,
            created_by_id,
            last_modified_by_id
        FROM {{ source('GENERAL', 'VEHICLE_HISTORY') }}
    ),

    renamed_cte AS (
        SELECT
            id                                                     AS vehicle_history_id,
            tenant__r__external_id__c                              AS tenant_id,

            created                                                AS created_datetime,
            cast(created AS date)                                  AS created_date,

            last_modified                                          AS last_modified_datetime,
            cast(last_modified AS date)                            AS last_modified_date,

            vehicle_id,
            license_plate_number,
            license_plate_state,
            concat(license_plate_number, ',', license_plate_state) AS license_plate_id,
            vif_id,
            color_id,
            event_type,
            subscription_id,
            price_id,
            created_by_id                                           AS created_by_user_id,
            last_modified_by_id                                     AS last_modified_by_user_id
        FROM source_cte
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
