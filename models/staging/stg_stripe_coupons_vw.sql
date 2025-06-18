--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            tenant__r__external_id__c,
            coupon_id,
            name,
            amount_off,
            percent_off,
            duration,
            duration_in_months,
            max_redemptions,
            redeem_by,
            device_limit,
            max_user_redemptions,
            deleted,
            coupon_created,
            created,
            last_modified,
            context,
            is_admin,
            is_fixed_discount,
            type,
            label_override,
            auto_cancel
        FROM {{ source('REPORTING', 'STRIPE_COUPONS') }}
    ),

    renamed_cte AS (
        SELECT
            tenant__r__external_id__c    AS tenant_id,
            coupon_id,
            name                         AS coupon_name,

            -- AMOUNT_OFF as amount_off_cents,
            amount_off / 100.0           AS amount_off_amt,
            percent_off,

            duration,
            duration_in_months,
            max_redemptions,
            redeem_by                    AS redeem_by_datetime,

            cast(redeem_by AS date)      AS redeem_by_date,
            device_limit,

            max_user_redemptions,
            deleted                      AS deleted_flag,
            coupon_created               AS coupon_created_datetime,

            cast(coupon_created AS date) AS coupon_created_date,
            created                      AS created_datetime,

            cast(created AS date)        AS created_date,
            last_modified                AS last_modified_datetime,

            cast(last_modified AS date)  AS last_modified_date,
            context,

            is_admin                     AS is_admin_flag,
            is_fixed_discount            AS is_fixed_discount_flag,
            type                         AS coupon_type,
            label_override,
            auto_cancel                  AS auto_cancel_flg,

        FROM source_cte
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
