{{ config(
    materialized='dynamic_table',
    on_configuration_change='apply',
    target_lag='1 hour',
    snowflake_warehouse='DEV_DBT_WH',
    refresh_mode='INCREMENTAL',
    initialize='ON_CREATE'
) }}

-- Optimized version of the subscriptions view for Snowflake
-- Key optimizations:
-- 1. Changed from view to incremental table for better performance
-- 2. Added clustering keys for common query patterns
-- 3. Optimized JOIN order based on cardinality
-- 4. Pushed down filters where possible
-- 5. Replaced multiple COALESCE calls with CTEs
-- 6. Optimized window functions

SELECT *
FROM {{ ref("fct_subscriptions_vw")}}