--DBT Model
--2025-05-23 Original model created by Patrick Callahan

{{ config(materialized='view') }}

with source_cte as (
    select
        TENANT__R__EXTERNAL_ID__C,
        COUPON_ID,
        NAME,
        AMOUNT_OFF,
        PERCENT_OFF,
        DURATION,
        DURATION_IN_MONTHS,
        MAX_REDEMPTIONS,
        REDEEM_BY,
        DEVICE_LIMIT,
        MAX_USER_REDEMPTIONS,
        DELETED,
        COUPON_CREATED,
        CREATED,
        LAST_MODIFIED,
        CONTEXT,
        IS_ADMIN,
        IS_FIXED_DISCOUNT,
        TYPE,
        LABEL_OVERRIDE,
        AUTO_CANCEL
    from {{ source('REPORTING', 'STRIPE_COUPONS') }}
),

renamed_cte as (
    select
        TENANT__R__EXTERNAL_ID__C as tenant_id,
        COUPON_ID as coupon_id,
        NAME as name,

        AMOUNT_OFF as amount_off_cents,
        AMOUNT_OFF/100.0 as amount_off_amt,

        PERCENT_OFF as percent_off,
        DURATION as duration,
        DURATION_IN_MONTHS as duration_in_months,
        MAX_REDEMPTIONS as max_redemptions,

        REDEEM_BY as redeem_by_datetime,
        cast(REDEEM_BY as date) as redeem_by_date,

        DEVICE_LIMIT as device_limit,
        MAX_USER_REDEMPTIONS as max_user_redemptions,
        DELETED as deleted_flg,

        COUPON_CREATED as coupon_created_datetime,
        cast(COUPON_CREATED as date) as coupon_created_date,

        CREATED as created_datetime,
        cast(CREATED as date) as created_date,

        LAST_MODIFIED as last_modified_datetime,
        cast(LAST_MODIFIED as date) as last_modified_date,

        CONTEXT as context,
        IS_ADMIN as is_admin_flg,
        IS_FIXED_DISCOUNT as is_fixed_discount_flg,
        TYPE as type,
        LABEL_OVERRIDE as label_override,
        AUTO_CANCEL as auto_cancel_flg
    from source_cte
),

final_cte as (
    select * from renamed_cte
)

select * from final_cte
