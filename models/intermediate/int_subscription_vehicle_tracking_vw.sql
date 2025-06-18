{{ config(materialized='view') }}

WITH
    vehicle AS (
        SELECT *
        FROM {{ ref('stg_vehicle_vw') }}
    ),

    lp_first_sub AS (
        SELECT
            tenant_id,
            license_plate_number,
            license_plate_state,
            license_plate_id,
            subscription_id,
            row_number() OVER (
                PARTITION BY tenant_id, concat(license_plate_number, ',', license_plate_state)
                ORDER BY vehicle_history_id ASC
            ) AS row_num
        FROM {{ ref('stg_vehicle_history_vw') }}
        QUALIFY row_num = 1
    ),

    lp_legacy_subs AS (
        SELECT
            tenant_id,
            license_plate_number
        FROM {{ ref('stg_internal_legacy_reactivation_vw') }}
    ),

    most_recent_rfid AS (
        SELECT
            vehicle_id,
            rfid,
            row_number() OVER (
                PARTITION BY vehicle_id
                ORDER BY vehicle_rfid_id DESC
            ) AS row_num
        FROM {{ ref('stg_vehicle_rfid_vw') }}
        QUALIFY row_num = 1
    )

SELECT
    v.subscription_id,
    v.vehicle_id,
    v.license_plate_number,
    v.license_plate_state,
    v.tenant_id,
    v.license_plate_id,
    lfs.subscription_id      AS first_subscription_id_for_plate,
    lls.license_plate_number AS is_legacy_reactivation,
    mrf.rfid                 AS most_recent_rfid
FROM vehicle AS v
    LEFT OUTER JOIN lp_first_sub AS lfs
        ON
            v.license_plate_id = lfs.license_plate_id
            AND v.tenant_id = lfs.tenant_id
    LEFT OUTER JOIN lp_legacy_subs AS lls
        ON
            v.license_plate_number = lls.license_plate_number
            AND v.tenant_id = lls.tenant_id
    LEFT OUTER JOIN most_recent_rfid AS mrf
        ON v.vehicle_id = mrf.vehicle_id
WHERE v.subscription_id IS NOT NULL