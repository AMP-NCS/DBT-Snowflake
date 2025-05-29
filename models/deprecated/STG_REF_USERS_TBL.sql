{{ config(
    materialized='incremental',
    unique_key='USER_ID',
    on_schema_change='sync_all_columns'
) }}

WITH source_cte1 AS (
    SELECT *
    FROM {{ source('GENERAL','MOBILEUSER__C') }}
),

source_cte2 AS (
    SELECT *
    FROM {{ source('GENERAL','CONTACT') }}
),

renamed AS (
    SELECT
        users.STRIPE_CUSTOMER_ID,
        users.EXTERNAL_ID__C AS USER_ID,
        users.TENANT__R__EXTERNAL_ID__C AS TENANT_ID,
        COALESCE(users.ZIP_CODE__C, users.BILLING_ZIP_CODE) AS USER_ZIP_CODE,
        COALESCE(users.EMAIL__C, contacts.EMAIL) AS USER_EMAIL,
        COALESCE(users.NAME, contacts.NAME) AS USER_NAME,
        users.CREATEDDATE AS USER_CREATED_DATETIME,
        users.LASTMODIFIEDDATE AS LAST_MODIFIED_DATETIME
    FROM source_cte1 users
    LEFT JOIN source_cte2 contacts
        ON users.CONTACT_ID = contacts.ID
)

SELECT *
FROM renamed

{% if is_incremental() %}
WHERE LAST_MODIFIED_DATETIME > (SELECT MAX(LAST_MODIFIED_DATETIME) FROM {{ this }})
{% endif %}