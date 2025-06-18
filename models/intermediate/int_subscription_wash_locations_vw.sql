--DBT Model
--2025-05-23 Original model created by Patrick Callahan
--2025-06-17 Updated to optimize query

{{
  config(
    materialized='view'
  )
}}

SELECT
    subscription_id,
    tenant_id,
    MIN_BY(autowash_location_id, mobile_user_activity_id) AS first_wash_location_id,
    MAX_BY(autowash_location_id, mobile_user_activity_id) AS last_wash_location_id,
    CURRENT_TIMESTAMP()                                   AS table_updated_at
FROM {{ ref('stg_mobile_user_activity_vw') }}
WHERE subscription_id IS NOT NULL
GROUP BY 1, 2
