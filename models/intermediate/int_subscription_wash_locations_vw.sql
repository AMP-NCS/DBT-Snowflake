{{
  config(
    materialized='view'
  )
}}

WITH
    wash_ranked AS (
        SELECT
            subscription_id,
            autowash_location_id,
            tenant_id,
            ROW_NUMBER() OVER (PARTITION BY subscription_id ORDER BY mobile_user_activity_id ASC)  AS first_row,
            ROW_NUMBER() OVER (PARTITION BY subscription_id ORDER BY mobile_user_activity_id DESC) AS last_row
        FROM {{ ref('stg_mobile_user_activity_vw') }}
        WHERE subscription_id IS NOT NULL
    ),

    first_and_last_wash AS (
        SELECT
            subscription_id,
            tenant_id,
            MAX(CASE WHEN first_row = 1 THEN autowash_location_id END) AS first_wash_location_id,
            MAX(CASE WHEN last_row = 1 THEN autowash_location_id END)  AS last_wash_location_id
        FROM wash_ranked
        GROUP BY 1,2
    )

SELECT *
FROM first_and_last_wash
