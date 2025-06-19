{{ config(materialized='view') }}

SELECT
    v.subscription_id,
    v.vehicle_id,
    v.license_plate_number,
    v.license_plate_state,
    v.tenant_id,
    v.license_plate_id,

    -- first subscription per plate
    lfs.first_subscription_id_for_plate,

    -- legacy reactivation flag (TRUE if we found a match)
    coalesce (lls.license_plate_number IS NOT NULL, FALSE)
        AS is_legacy_reactivation,

    -- most recent RFID
    mrf.rfid                                               AS most_recent_rfid

    -- current_timestamp()                                    AS table_updated_at

FROM {{ ref('stg_vehicle_vw') }} AS v

-- first‐subscription per plate
    LEFT OUTER JOIN (
        SELECT
            tenant_id,
            license_plate_id,
            subscription_id AS first_subscription_id_for_plate
        FROM {{ ref('stg_vehicle_history_vw') }}
        WHERE subscription_id IS NOT NULL
        QUALIFY row_number() OVER (PARTITION BY tenant_id, license_plate_id ORDER BY vehicle_history_id ASC) = 1
    ) lfs
        ON
            v.tenant_id = lfs.tenant_id
            AND v.license_plate_id = lfs.license_plate_id

    -- legacy reactivation lookup
    LEFT OUTER JOIN {{ ref('stg_internal_legacy_reactivation_vw') }} AS lls
        ON
            v.tenant_id = lls.tenant_id
            AND v.license_plate_number = lls.license_plate_number

    -- most‐recent RFID per vehicle
    LEFT OUTER JOIN (
        SELECT
            vehicle_id,
            rfid
        FROM {{ ref('stg_vehicle_rfid_vw') }}
        QUALIFY row_number() OVER (PARTITION BY vehicle_id ORDER BY vehicle_rfid_id DESC) = 1
    ) AS mrf
        ON v.vehicle_id = mrf.vehicle_id

WHERE v.subscription_id IS NOT NULL
