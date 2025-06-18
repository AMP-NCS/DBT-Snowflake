--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            autowash_location__r__external_id__c,
            wash_type_category__r__external_id__c,
            name,
            wash_type__r__external_id__c,
            lastmodifieddate,
            service__c,
            external_id__c,
            createddate,
            code__r__external_id__c,
            -- price__c,
            mobile_user__r__external_id__c,
            id,
            pay_per_service__c,
            is_member__c,
            internal_cost__c,
            discounted_price__c,
            list_price__c,
            account_type__c,
            finished_date__c,
            autowash_account__r__external_id__c,
            tenant__r__external_id__c,
            is_wash_upgrade,
            vehicle_history_id,
            add_on_price__c,
            stripe_invoice_id,
            tax_rate_id,
            tax_rate,
            pre_tax_total,
            tax_amount,
            post_tax_total,
            credits_applied,
            discounts_applied,
            coupon_code,
            prepaid_wash_recipient_wash_id,
            user_coupon_id,
            created_by_id,
            last_modified_by_id,
            stripe_invoice_url,
            subscription_id,
            created_by_admin_id,
            kiosk_id,
            redemption_method,
            payment_source,
            stored_wash_id,
            tip_amount,
            rfid_history_id,
            status_id,
            status_modified,
            mobile_app_discount,
            pos_plan_imported_id,
            has_attachments,
            transaction_id,
            customer_type_id
        FROM {{ source('GENERAL', 'MOBILE_USER_ACTIVITY') }}
    ),

    renamed_cte AS (
        SELECT
            autowash_location__r__external_id__c     AS autowash_location_id,
            wash_type_category__r__external_id__c    AS wash_type_category_id,
            name,
            wash_type__r__external_id__c             AS wash_type_id,

            lastmodifieddate                         AS last_modified_datetime,
            cast(lastmodifieddate AS date)           AS last_modified_date,

            service__c                               AS service,
            external_id__c                           AS mobile_user_activity_id,

            createddate                              AS created_datetime,
            cast(createddate AS date)                AS created_date,

            code__r__external_id__c                  AS code_id,

            mobile_user__r__external_id__c           AS user_id,

            id                                       AS mobile_user_activity_number,
            pay_per_service__c                       AS pay_per_service_flag,
            is_member__c                             AS is_member_flag,

            internal_cost__c                         AS internal_cost_amt,
            discounted_price__c                      AS discounted_price_amt,
            list_price__c                            AS list_price_amt,

            account_type__c                          AS account_type,

            finished_date__c                         AS finished_datetime,
            cast(finished_date__c AS date)           AS finished_date,

            autowash_account__r__external_id__c      AS account_id,
            tenant__r__external_id__c                AS tenant_id,
            is_wash_upgrade                          AS is_wash_upgrade_flg,

            vehicle_history_id,
            add_on_price__c                          AS add_on_price_amt,
            stripe_invoice_id,
            tax_rate_id,
            tax_rate,

            cast(pre_tax_total AS decimal(9, 2))     AS pre_tax_total_amt,
            cast(tax_amount AS decimal(9, 2))        AS tax_amt,
            cast(post_tax_total AS decimal(9, 2))    AS post_tax_total_amt,
            cast(credits_applied AS decimal(9, 2))   AS credits_applied_amt,
            cast(discounts_applied AS decimal(9, 2)) AS discounts_applied_amt,

            coupon_code,
            prepaid_wash_recipient_wash_id,
            user_coupon_id,
            created_by_id                            AS created_by_user_id,
            last_modified_by_id                      AS last_modified_by_user_id,
            stripe_invoice_url,
            subscription_id,
            created_by_admin_id                      AS created_by_admin_user_id,
            kiosk_id,
            redemption_method,
            payment_source,
            stored_wash_id,
            tip_amount                               AS tip_amount_amt,
            rfid_history_id,

            status_id,

            status_modified                          AS status_modified_datetime,
            cast(status_modified AS date)            AS status_modified_date,

            mobile_app_discount                      AS mobile_app_discount_amt,
            pos_plan_imported_id,
            has_attachments                          AS has_attachments_flg,
            transaction_id,
            customer_type_id
        FROM source_cte
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
