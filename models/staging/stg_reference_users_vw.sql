{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            users.tenant__r__external_id__c,
            users.external_id__c,
            users.stripe_customer_id,
            users.billing_zip_code,
            users.zip_code__c,
            employees.employee_external_identifier                      AS employee_id,
            COALESCE(contacts.email, users.email__c)                    AS email__c,
            COALESCE(contacts.name, users.name)                         AS name,
            COALESCE(phone_numbers.phone_number, users.phone_number__c)
                AS phone_number__c
        FROM {{ source('GENERAL','MOBILEUSER__C') }} AS users

            LEFT OUTER JOIN {{ source('GENERAL','CONTACT') }} AS contacts
                ON users.contact_id = contacts.id

            LEFT OUTER JOIN {{ source('GENERAL','CONTACT_PHONE_NUMBER') }} AS phone_numbers
                ON
                    users.contact_id = phone_numbers.contact_id
                    AND phone_numbers.is_primary = TRUE

            LEFT OUTER JOIN {{ source('GENERAL','EMPLOYEE') }} AS employees
                ON users.external_id__c = employees.mobile_user_id
    ),

    renamed_cte AS (
        SELECT
            tenant__r__external_id__c AS tenant_id,
            external_id__c            AS user_id,
            stripe_customer_id,
            billing_zip_code,
            zip_code__c               AS zip_code,
            email__c                  AS email,
            name,
            phone_number__c           AS phone_number,
            employee_id
        FROM source_cte
    ),

    final_cte AS (
        SELECT *
        FROM renamed_cte
    )

SELECT * FROM final_cte
