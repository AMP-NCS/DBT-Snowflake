{{ config(materialized='view') }}

-- This model replicates the logic of the legacy AMP_DB_DEV.VIEWS.SUBSCRIPTIONS view using dbt models
-- It leverages staging/intermediate models for each CTE where possible

with 

subs as (
    select * from {{ ref('stg_stripe_subscriptions_vw') }}
),

users as (
    select * from {{ ref('stg_reference_users_vw') }}
),

invoice_count as (
    select subscription_id, 
    count(*) as number_of_paid_invoices_to_date
    from {{ ref('stg_stripe_invoices_vw') }}
    where status = 'paid'
      and billing_reason in ('subscription_create','subscription_cycle')
    group by subscription_id
),

first_invoice as (
    select subscription_id, 
    subtotal_amt, 
    discount_amt
    from {{ ref('stg_stripe_invoices_vw') }} inv
    where status = 'paid'
      and billing_reason in ('subscription_create','subscription_cycle')
      and invoice_created_datetime in (
        select min(invoice_created_datetime)
        from {{ ref('stg_stripe_invoices_vw') }}
        where subscription_id = inv.subscription_id
        group by subscription_id
      )
),

combined_vehicle_info as (
    select
        vh.vehicle_id,
        vh.tenant_id,
        vh.license_plate_number,
        vh.license_plate_state,
        vh.license_plate_id,
        -- Most recent RFID for this vehicle
        first_value(vrf.rfid) over (partition by vh.vehicle_id order by vrf.vehicle_rfid_id desc) as most_recent_rfid,
        -- First subscription for this license plate (and tenant)
        first_value(vh.subscription_id) over (
            partition by vh.tenant_id, vh.license_plate_number, vh.license_plate_state
            order by vh.vehicle_history_id asc
        ) as first_subscription_id
    from {{ ref('stg_vehicle_history_vw') }} vh
    left join {{ ref('stg_vehicle_rfid_vw') }} vrf
        on vh.vehicle_id = vrf.vehicle_id
    qualify row_number() over (partition by vh.vehicle_id order by vh.vehicle_history_id desc) = 1
)
-- most_recent_rfid as (
--     select vehicle_id, 
--     rfid
--     from {{ ref('stg_vehicle_rfid_vw') }}
--     qualify row_number() over (partition by vehicle_id order by vehicle_rfid_id desc) = 1
-- ),

-- lp_first_sub as (
--     select tenant_id, concat(license_plate_number,',',license_plate_state) as lp_id, subscription_id
--     from {{ ref('stg_vehicle_history_vw') }}
--     qualify row_number() over (partition by tenant_id, concat(license_plate_number,',',license_plate_state) order by vehicle_history_id asc) = 1
-- ),

lp_legacy_subs as (
    select tenant_id, license_plate_number
    from {{ ref('stg_internal_legacy_reactivation_vw') }}
),

product_details as (
    select * from {{ ref('stg_reference_product_price_vw') }}
),

canc as (
    select * from {{ ref('stg_subscription_cancellations_vw') }} qualify row_number() over (partition by stripe_subscription_id order by created_datetime desc) = 1
),

status_pre_canc as (
    select subscription_id, status_previous
    from {{ ref('stg_stripe_subscription_history_vw') }}
    where status_current = 'canceled' and status_previous <> status_current
),

last_charge_failure as (
    select i.subscription_id, c.failure_message, c.failure_code, c.payment_method_details_card_funding,
           row_number() over (partition by i.subscription_id order by c.charge_created_datetime desc) as row_num
    from {{ ref('stg_stripe_charges_vw') }} c
    join {{ ref('stg_stripe_invoices_vw') }} i on c.invoice_id = i.invoice_id
    where c.failure_message is not null and i.subscription_id is not null
),

-- plans_first_wash as (
--     select subscription_id, l.internal_name as first_wash_location
--     from {{ ref('stg_mobile_user_activity_vw') }} a
--     join {{ ref('stg_reference_location_vw') }} l on a.autowash_location_id = l.location_id
--     qualify row_number() over (partition by subscription_id order by mobile_user_activity_number asc) = 1
-- ),

-- plans_last_wash as (
--     select subscription_id, l.internal_name as last_wash_location
--     from {{ ref('stg_mobile_user_activity_vw') }} a
--     join {{ ref('stg_reference_location_vw') }} l on a.autowash_location_id = l.location_id
--     qualify row_number() over (partition by subscription_id order by mobile_user_activity_number desc) = 1
-- ),

-- coupons_impacting_next_invoice as (
--     select d.subscription_id, c.*, row_number() over (partition by d.subscription_id order by d.start_datetime) as row_num
--     from {{ ref('stg_stripe_discounts_vw') }} d
--     join {{ ref('stg_stripe_coupons_vw') }} c on d.coupon_id = c.coupon_id
--     where d.discount_source_id is not null
-- ),

-- first_price_id as (
--     select subscription_id, price_id_current
--     from {{ ref('stg_stripe_subscription_item_history_vw') }}
--     where price_id_current is not null
--     qualify row_number() over (partition by subscription_id order by stripe_subscription_item_history_id asc) = 1
-- ),



-- subscription_items as (
--     select * from {{ ref('stg_stripe_subscription_items_vw') }}
-- )

select
    subs.tenant_id as tenant_id,
    subs.stripe_customer_id,
    subs.stripe_subscription_id
    users.email as customer_email,
    users.name as customer_name,
    users.phone_number as customer_phone_number,

    COALESCE(migrated_unique_tenant_location_code, override_unique_tenant_location_id, subscription_unique_tenant_location_id, signup_unique_tenant_location_id) AS assigned_unique_tenant_location_id,
    
    migrated_unique_tenant_location_code AS legacy_unique_tenant_location_code,

    COALESCE(override_unique_tenant_location_id, subscription_unique_tenant_location_id, signup_unique_tenant_location_id) AS signup_unique_tenant_location_id,

    IFF(subscription_created_date < '2023-10-04' AND users.stripe_customer_id IS NULL, sign_up_by_user_id, stripe_customer_id) AS attendant_customer_id,

    migrated_plan_flag,

    subs.new_status,
    subs.status,

    subs.cancel_at_period_end,  
    subs.coupon_id,

    subs.plan_created_date,
    subs.plan_start_date,

    subs.current_period_end,
    subs.plan_cancel_request_date,
    subs.plan_cancel_scheduled_for_date,
    subs.plan_end_date,
    canc.created_date as cancellation_created_date,
    subs.pause_request_date,
    subs.pause_effective_date,
    subs.pause_end_date,
    subs.auto_cancel_date,
    subs.pending_downgrade_date,

    product_details.product_name AS pre_downgrade_plan_name,

    combined_vehicle_info.most_recent_rfid,
    combined_vehicle_info.license_plate_number,
    combined_vehicle_info.license_plate_state,
    combined_vehicle_info.license_plate_id,

    CASE
            WHEN SUBS.STATUS <> 'canceled'
                THEN NULL
            WHEN SUBS.CANCELLATION_DETAILS_REASON = 'payment_disputed'
                THEN 'Canceled by Dispute'
            WHEN CANC.CREATED_BY_ID = CUSTOMERS.EXTERNAL_ID__C
                THEN 'Canceled by Customer'
            WHEN SUBS.CANCELLATION_DETAILS_REASON = 'cancellation_requested'
                OR (CANC.STRIPE_SUBSCRIPTION_ID__C IS NOT NULL AND CANC.CREATED_BY_ID <> CUSTOMERS.EXTERNAL_ID__C)
                    THEN 'Canceled by Employee'
            WHEN SUBS.CANCELLATION_DETAILS_REASON = 'payment_failed'
                OR STATUS_PRE_CANC.STATUS_PREVIOUS IN ('unpaid','past_due')
                    THEN 'Failed Payments'
            ELSE 'Unknown'
            END AS CANCELATION_METHOD,
    canc.cancellation_created_by_customer_id,
    canc.picklist_value_id,
    canc.comment,

    IFF(CANCELATION_METHOD = 'Failed Payments', LAST_CHARGE_FAILURE.FAILURE_MESSAGE, NULL) AS FAILED_PAYMENT_REASON,
    IFF(CANCELATION_METHOD = 'Failed Payments', INITCAP(LAST_CHARGE_FAILURE.PAYMENT_METHOD_DETAILS_CARD_FUNDING), NULL) AS FAILED_PAYMENT_CARD_TYPE,

    invoice_count.number_of_paid_invoices_to_date,
    first_invoice.subtotal_amt - first_invoice.discount_amt AS first_invoice_amt,
    
    -- CASE WHEN sub.migrated_subscription_id IS NULL AND first_subscription_id <> subs.stripe_subscription_id

    


    -- si.subscription_id as stripe_subscription_id,
    -- si.subscription_item_id as stripe_subscription_item_id,
    -- subs.plan_created_date as plan_created_date,
    -- subs.plan_start_date as plan_start_date,
    -- -- Plan type logic
    -- case
    --     when product_details.fleet_strategy = 'PayPerWash' then 'Fleet Pay Per Wash'
    --     when product_details.plan_type = 'Fleet' then 'Fleet Unlimited Plan'
    --     when si.quantity > 1 then 'Family Plan'
    --     else 'Standard Plan'
    -- end as plan_type,
    -- product_details.plan_name as plan_name,
    -- coalesce(original_product_details.plan_name, product_details.plan_name) as original_plan_name,
    -- si.quantity as plan_quantity,
    -- product_details.price_group as price_group,
    -- concat(product_details.interval_count, ' ', product_details.interval_type,
    --     case when product_details.interval_count > 1 then 'S' else '' end) as plan_term,

    -- TODO: Add all remaining business logic fields as in the original view
from subs
left join users on subs.stripe_customer_id = users.stripe_customer_id
left join invoice_count on subs.stripe_subscription_id = invoice_count.subscription_id
left join first_invoice on subs.stripe_subscription_id = first_invoice.subscription_id
left join combined_vehicle_info on subs.stripe_subscription_id = combined_vehicle_info.first_subscription_id
          AND subs.license_plate_id = combined_vehicle_info.license_plate_id
left join lp_legacy_subs on combined_vehicle_info.license_plate_number = lp_legacy_subs.license_plate_number
          AND combined_vehicle_info.tenant_id = lp_legacy_subs.tenant_id
left join canc on subs.stripe_subscription_id = canc.subscription_id
left join product_details on subs.downgrade_price_id = product_details.stripe_price_id
left join status_pre_canc on subs.stripe_subscription_id = status_pre_canc.subscription_id
left join last_charge_failure on subs.stripe_subscription_id = last_charge_failure.subscription_id

-- subscription_items si
-- inner join subs on si.subscription_id = subs.stripe_subscription_id
-- inner join product_details on si.price_id = product_details.stripe_price_id

-- left join first_price_id on subs.stripe_subscription_id = first_price_id.subscription_id
-- left join product_details as original_product_details on first_price_id.price_id_current = original_product_details.stripe_price_id


-- left join coupons_impacting_next_invoice as coupons_1 on subs.stripe_subscription_id = coupons_1.subscription_id and coupons_1.row_num = 1
-- left join coupons_impacting_next_invoice as coupons_2 on subs.stripe_subscription_id = coupons_2.subscription_id and coupons_2.row_num = 2
-- left join plans_first_wash on subs.stripe_subscription_id = plans_first_wash.subscription_id
-- left join plans_last_wash on subs.stripe_subscription_id = plans_last_wash.subscription_id

-- Add all other joins and calculated fields as in the original view
-- This is a partial implementation; continue to add all fields and logic as needed 