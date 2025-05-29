{{ config(materialized='view') }}
   
with source_cte as (
    select
        users.TENANT__R__EXTERNAL_ID__C          as TENANT__R__EXTERNAL_ID__C,
        users.EXTERNAL_ID__C                    as EXTERNAL_ID__C,
        users.STRIPE_CUSTOMER_ID                as STRIPE_CUSTOMER_ID,
        users.BILLING_ZIP_CODE                  as BILLING_ZIP_CODE,
        users.ZIP_CODE__C                       as ZIP_CODE__C,
        COALESCE(contacts.EMAIL, users.EMAIL__C)  as EMAIL__C,
        COALESCE(contacts.NAME, users.NAME)       as NAME,
        COALESCE(phone_numbers.PHONE_NUMBER, users.PHONE_NUMBER__C)
                                                as PHONE_NUMBER__C,
        employees.EMPLOYEE_EXTERNAL_IDENTIFIER  as EMPLOYEE_ID
    from {{ source('GENERAL','MOBILEUSER__C') }} as users
    
    left join {{ source('GENERAL','CONTACT') }} as contacts
      on users.CONTACT_ID = contacts.ID
    
    left join {{ source('GENERAL','CONTACT_PHONE_NUMBER') }} as phone_numbers
      on users.CONTACT_ID = phone_numbers.CONTACT_ID
      and phone_numbers.IS_PRIMARY = true
    
    left join {{ source('GENERAL','EMPLOYEE') }} as employees
      on users.EXTERNAL_ID__C = employees.MOBILE_USER_ID
),

renamed_cte as (
    select
        TENANT__R__EXTERNAL_ID__C    as tenant_id,
        EXTERNAL_ID__C               as external_user_id,
        STRIPE_CUSTOMER_ID           as stripe_customer_id,
        BILLING_ZIP_CODE             as billing_zip_code,
        ZIP_CODE__C                  as zip_code,
        EMAIL__C                     as email,
        NAME                         as name,
        PHONE_NUMBER__C              as phone_number,
        EMPLOYEE_ID                  as employee_id
    from source_cte
),

final_cte as (
    select *
    from renamed_cte
)

select * from final_cte
