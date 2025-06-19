# DBT Documentation Blocks for Staging Models

Below are dbt doc blocks for each table and each unique column in the staging models. Copy these into your dbt project as needed.

---

## Table Docs

{% docs stg_autowash_account_vw %}
Staging model for Autowash Account data from GENERAL.AUTOWASH_ACCOUNT__C. Contains account, subscription, and tenant details.
{% enddocs %}

{% docs stg_gift_card_promotion_vw %}
Staging model for Gift Card Promotion data from GENERAL.GIFT_CARD_PROMOTION. Contains promotion, pricing, and tenant details.
{% enddocs %}

{% docs stg_gift_card_transaction_invoice_vw %}
Staging model for Gift Card Transaction Invoice data from GENERAL.GIFT_CARD_TRANSACTION_INVOICE.
{% enddocs %}

{% docs stg_gift_card_transaction_purchase_vw %}
Staging model for Gift Card Transaction Purchase data from GENERAL.GIFT_CARD_TRANSACTION_PURCHASE.
{% enddocs %}

{% docs stg_gift_card_transaction_vw %}
Staging model for Gift Card Transaction data from GENERAL.GIFT_CARD_TRANSACTION.
{% enddocs %}

{% docs stg_internal_legacy_reactivation_vw %}
Staging model for legacy reactivation checks from INTERNAL.LEGACY_REACTIVATION_CHECK.
{% enddocs %}

{% docs stg_mobile_user_activity_vw %}
Staging model for mobile user activity from GENERAL.MOBILE_USER_ACTIVITY. Tracks user actions, payments, and related metadata.
{% enddocs %}

{% docs stg_reference_location_vw %}
Staging model for reference location data, combining location and hierarchy attributes.
{% enddocs %}

{% docs stg_reference_picklist_vw %}
Staging model for picklist values from GENERAL.PICKLIST_VALUE.
{% enddocs %}

{% docs stg_reference_product_price_vw %}
Staging model for product and price reference data, joining Stripe and AMP product/price sources.
{% enddocs %}

{% docs stg_reference_users_vw %}
Staging model for user reference data, joining user, contact, and employee sources.
{% enddocs %}

{% docs STG_REF_LOCATIONS_TBL %}
Staging model for location reference data. Combines core location details from AUTOWASHLOCATION__C with hierarchy attributes from LOCATION_HIERARCHY. Materialized as an incremental table based on the LAST_MODIFIED_DATETIME.
{% enddocs %}

{% docs stg_stripe_charges_vw %}
Staging model for Stripe charge data from REPORTING.STRIPE_CHARGES. Contains charge, payment, and card details.
{% enddocs %}

{% docs stg_stripe_coupons_vw %}
Staging model for Stripe coupon data from REPORTING.STRIPE_COUPONS. Contains coupon, discount, and duration details.
{% enddocs %}

{% docs stg_stripe_discounts_vw %}
Staging model for Stripe discount data from REPORTING.STRIPE_DISCOUNTS. Contains discount, coupon, and subscription details.
{% enddocs %}

{% docs stg_stripe_invoice_line_items_vw %}
Staging model for Stripe invoice line items from REPORTING.STRIPE_INVOICE_LINE_ITEMS. Contains line item, product, and tax details.
{% enddocs %}

{% docs stg_stripe_invoices_vw %}
Staging model for Stripe invoices from REPORTING.STRIPE_INVOICES. Contains invoice, payment, and status details.
{% enddocs %}

{% docs stg_stripe_subscription_history_vw %}
Staging model for Stripe subscription history from REPORTING.STRIPE_SUBSCRIPTION_HISTORIES. Tracks changes to subscription status and billing.
{% enddocs %}

{% docs stg_stripe_subscription_item_history_vw %}
Staging model for Stripe subscription item history from REPORTING.STRIPE_SUBSCRIPTION_ITEM_HISTORIES. Tracks changes to subscription items.
{% enddocs %}

{% docs stg_stripe_subscription_items_vw %}
Staging model for Stripe subscription items from REPORTING.STRIPE_SUBSCRIPTION_ITEMS. Contains subscription item, price, and quantity details.
{% enddocs %}

{% docs stg_stripe_subscriptions_vw %}
Staging model for Stripe subscriptions from REPORTING.STRIPE_SUBSCRIPTIONS. Contains subscription, status, and location details.
{% enddocs %}

{% docs stg_subscription_cancellations_vw %}
Staging model for subscription cancellations from GENERAL.SUBSCRIPTION_CANCELLATION__C. Contains cancellation, reason, and user details.
{% enddocs %}

{% docs stg_vehicle_history_vw %}
Staging model for vehicle history from GENERAL.VEHICLE_HISTORY. Contains vehicle, event, and subscription details.
{% enddocs %}

{% docs stg_vehicle_rfid_vw %}
Staging model for vehicle RFID data from GENERAL.VEHICLE_RFID. Contains RFID, vehicle, and integration details.
{% enddocs %}

{% docs stg_vehicle_vw %}
Staging model for vehicle data from GENERAL.VEHICLE. Contains vehicle, account, and subscription details.
{% enddocs %}

---

## Column Docs

{% docs account_external_id %}
External ID for the account.
{% enddocs %}

{% docs account_id %}
ID of the account.
{% enddocs %}

{% docs active_flag %}
Flag indicating if the promotion is active.
{% enddocs %}

{% docs active_subscription_id %}
ID of the active subscription.
{% enddocs %}

{% docs allow_pay_per_wash_flg %}
Flag indicating if pay-per-wash is allowed.
{% enddocs %}

{% docs amp_product_id %}
AMP product ID.
{% enddocs %}

{% docs amp_product_price_id %}
AMP product price ID.
{% enddocs %}

{% docs amount_off_amt %}
Amount off (in dollars).
{% enddocs %}

{% docs aaa_membership_number %}
AAA membership number.
{% enddocs %}

{% docs auto_cancel_date %}
Date when auto cancel is set.
{% enddocs %}

{% docs auto_cancel_flg %}
Flag indicating if the coupon auto-cancels.
{% enddocs %}

{% docs autowash_account_id %}
Unique identifier for the Autowash Account.
{% enddocs %}

{% docs autowash_account_holder_user_id %}
External ID of the primary account holder user.
{% enddocs %}

{% docs billing_cycle_anchor_date %}
Billing cycle anchor date.
{% enddocs %}

{% docs billing_reason %}
Reason for billing.
{% enddocs %}

{% docs cancel_at_period_end_flag %}
Flag indicating if the subscription is set to cancel at period end.
{% enddocs %}

{% docs cancellation_comment %}
Comment for the cancellation.
{% enddocs %}

{% docs cancellation_created_by_user_id %}
User ID who created the cancellation.
{% enddocs %}

{% docs cancellation_details_reason %}
Reason for cancellation.
{% enddocs %}

{% docs cancellation_id %}
Unique identifier for the cancellation.
{% enddocs %}

{% docs cancellation_last_modified_by_user_id %}
User ID who last modified the cancellation.
{% enddocs %}

{% docs cancellation_name_code %}
Name/code for the cancellation.
{% enddocs %}

{% docs cancellation_reason_code %}
Reason code for the cancellation.
{% enddocs %}

{% docs categorized_rls_id %}
Categorized row-level security ID.
{% enddocs %}

{% docs charge_amt %}
Charge amount (in dollars).
{% enddocs %}

{% docs charge_created_datetime %}
Timestamp when the charge was created.
{% enddocs %}

{% docs charge_id %}
Unique identifier for the Stripe charge.
{% enddocs %}

{% docs checkout_id %}
ID of the checkout.
{% enddocs %}

{% docs city %}
City of the location.
{% enddocs %}

{% docs color_id %}
Color ID.
{% enddocs %}

{% docs collection_method %}
Collection method for the invoice.
{% enddocs %}

{% docs coupon_id %}
ID of the coupon.
{% enddocs %}

{% docs coupon_id_current %}
Current coupon ID.
{% enddocs %}

{% docs coupon_id_previous %}
Previous coupon ID.
{% enddocs %}

{% docs coupon_name %}
Name of the coupon.
{% enddocs %}

{% docs coupon_type %}
Type of the coupon.
{% enddocs %}

{% docs created_by_admin_id %}
ID of the admin who created the subscription.
{% enddocs %}

{% docs created_by_admin_user_id %}
ID of the admin who created the invoice.
{% enddocs %}

{% docs created_date %}
Date when the record was created.
{% enddocs %}

{% docs created_datetime %}
Timestamp when the record was created.
{% enddocs %}

{% docs credit_card_brand %}
Brand of the credit card used.
{% enddocs %}

{% docs credit_card_country %}
Country of the credit card.
{% enddocs %}

{% docs credit_card_expiration_month %}
Expiration month of the credit card.
{% enddocs %}

{% docs credit_card_expiration_year %}
Expiration year of the credit card.
{% enddocs %}

{% docs credit_card_last_four %}
Last four digits of the credit card.
{% enddocs %}

{% docs current_period_end_date %}
End date of the current period.
{% enddocs %}

{% docs current_period_start_date %}
Start date of the current period.
{% enddocs %}

{% docs deleted_flag %}
Flag indicating if the coupon is deleted.
{% enddocs %}

{% docs description %}
Description of the line item.
{% enddocs %}

{% docs disputed_flag %}
Flag indicating if the charge is disputed.
{% enddocs %}

{% docs downgrade_expiration_date %}
Date when downgrade expires.
{% enddocs %}

{% docs downgrade_price_id %}
ID of the downgrade price.
{% enddocs %}

{% docs due_amt %}
Amount due (in dollars).
{% enddocs %}

{% docs email %}
Email address of the user.
{% enddocs %}

{% docs employee_id %}
Employee ID if the user is an employee.
{% enddocs %}

{% docs event_type %}
Type of the event.
{% enddocs %}

{% docs failure_message %}
Failure message if the charge failed.
{% enddocs %}

{% docs gift_card_id %}
ID of the related gift card.
{% enddocs %}

{% docs gift_card_line_item %}
Indicates if the line item is a gift card transaction.
{% enddocs %}

{% docs gift_card_promotion_id %}
ID of the related gift card promotion.
{% enddocs %}

{% docs gift_card_transaction_amt %}
Transaction amount (in dollars).
{% enddocs %}

{% docs gift_card_transaction_id %}
ID of the related gift card transaction.
{% enddocs %}

{% docs gift_card_transaction_invoice_id %}
Unique identifier for the gift card transaction invoice.
{% enddocs %}

{% docs gift_card_transaction_purchase_id %}
Unique identifier for the gift card transaction purchase.
{% enddocs %}

{% docs id %}
Unique identifier.
{% enddocs %}

{% docs integration_id %}
Integration ID.
{% enddocs %}

{% docs integration_metadata %}
Integration metadata.
{% enddocs %}

{% docs invoice_created_datetime %}
Timestamp when the invoice was created.
{% enddocs %}

{% docs invoice_id %}
ID of the invoice.
{% enddocs %}

{% docs invoice_line_item_amt %}
Amount for the invoice line item (in dollars).
{% enddocs %}

{% docs invoice_line_item_discount_amt %}
Discount amount for the line item (in dollars).
{% enddocs %}

{% docs invoice_line_item_id %}
Unique identifier for the invoice line item.
{% enddocs %}

{% docs invoice_line_item_tax_amt %}
Tax amount for the line item (in dollars).
{% enddocs %}

{% docs invoice_pdf_url %}
URL to the invoice PDF.
{% enddocs %}

{% docs is_admin_flag %}
Flag indicating if the coupon is admin-created.
{% enddocs %}

{% docs is_cancelled_flag %}
Flag indicating if the subscription is cancelled.
{% enddocs %}

{% docs is_fixed_discount_flag %}
Flag indicating if the coupon is a fixed discount.
{% enddocs %}

{% docs is_franchise_flag %}
Flag indicating if the location is a franchise.
{% enddocs %}

{% docs is_gift_card_flag %}
Flag indicating if the invoice is for a gift card.
{% enddocs %}

{% docs is_guest_purchase_flag %}
Flag indicating if the purchase was made by a guest.
{% enddocs %}

{% docs is_temp_tag_flag %}
Flag indicating if the vehicle has a temporary tag.
{% enddocs %}

{% docs last_modified_by_user_id %}
User ID who last modified the record.
{% enddocs %}

{% docs last_modified_date %}
Date when the record was last modified.
{% enddocs %}

{% docs last_modified_datetime %}
Timestamp when the record was last modified.
{% enddocs %}

{% docs license_plate_id %}
Combined license plate number and state.
{% enddocs %}

{% docs license_plate_number %}
License plate number.
{% enddocs %}

{% docs license_plate_state %}
State of the license plate.
{% enddocs %}

{% docs location_city %}
City where the location is situated.
{% enddocs %}

{% docs location_code %}
Short internal code for the location.
{% enddocs %}

{% docs location_external_id %}
External identifier for the location.
{% enddocs %}

{% docs location_id %}
ID of the location.
{% enddocs %}

{% docs location_image_url %}
Image URL or visual representation of the location.
{% enddocs %}

{% docs location_internal_name %}
Internal system name for the location.
{% enddocs %}

{% docs location_name %}
Human-readable name of the location.
{% enddocs %}

{% docs location_state %}
State or region of the location.
{% enddocs %}

{% docs location_street1 %}
Primary street address of the location.
{% enddocs %}

{% docs location_street2 %}
Secondary address line, if available.
{% enddocs %}

{% docs location_zip_code %}
Postal ZIP code of the location.
{% enddocs %}

{% docs marked_uncollectible_at_date %}
Date when the invoice was marked uncollectible.
{% enddocs %}

{% docs migrated_plan_flag %}
Flag indicating if the plan was migrated.
{% enddocs %}

{% docs migrated_pos_location_code %}
Migrated POS location code.
{% enddocs %}

{% docs migrated_unique_tenant_location_code %}
Unique tenant-location code for the migration.
{% enddocs %}

{% docs model_label_override %}
Model label override.
{% enddocs %}

{% docs name %}
Name of the account or user.
{% enddocs %}

{% docs new_status %}
Calculated new status for the subscription.
{% enddocs %}

{% docs ordinal %}
Ordinal position of the picklist value.
{% enddocs %}

{% docs paid_amt %}
Amount paid (in dollars).
{% enddocs %}

{% docs paid_at_datetime %}
Datetime when the invoice was paid.
{% enddocs %}

{% docs paid_out_of_band_flag %}
Flag indicating if the invoice was paid out of band.
{% enddocs %}

{% docs payment_method_id %}
ID of the payment method.
{% enddocs %}

{% docs percent_off %}
Percent off for the coupon.
{% enddocs %}

{% docs phone_number %}
Phone number of the user.
{% enddocs %}

{% docs picklist_id %}
ID of the picklist.
{% enddocs %}

{% docs picklist_key %}
Key for the picklist value.
{% enddocs %}

{% docs picklist_value %}
Value for the picklist.
{% enddocs %}

{% docs picklist_value_id %}
ID of the picklist value.
{% enddocs %}

{% docs plan_cancel_request_date %}
Date when plan cancel was requested.
{% enddocs %}

{% docs plan_cancel_scheduled_for_date %}
Date when plan cancel is scheduled for.
{% enddocs %}

{% docs plan_end_date %}
End date of the plan.
{% enddocs %}

{% docs plan_start_date %}
Start date of the plan.
{% enddocs %}

{% docs prepaid_wash_promotion_id %}
ID of the prepaid wash promotion.
{% enddocs %}

{% docs price_group_id %}
ID of the price group.
{% enddocs %}

{% docs price_group_name %}
Name of the price group.
{% enddocs %}

{% docs price_id %}
ID of the price.
{% enddocs %}

{% docs primary_account_holder_user_id %}
External ID of the primary account holder user.
{% enddocs %}

{% docs proration_flag %}
Flag indicating if the line item is a proration.
{% enddocs %}

{% docs product_category %}
Category of the product.
{% enddocs %}

{% docs product_id %}
ID of the product.
{% enddocs %}

{% docs product_name %}
Name of the product.
{% enddocs %}

{% docs promo_code_id %}
ID of the promo code.
{% enddocs %}

{% docs promotion_code_id %}
ID of the related promotion code.
{% enddocs %}

{% docs promotion_code_id_current %}
Current promotion code ID.
{% enddocs %}

{% docs promotion_code_id_previous %}
Previous promotion code ID.
{% enddocs %}

{% docs promotion_id %}
Unique identifier for the promotion.
{% enddocs %}

{% docs purchase_price_amt %}
Purchase price of the gift card promotion (in dollars).
{% enddocs %}

{% docs purchased_by_guest_email %}
Email of the guest purchaser.
{% enddocs %}

{% docs purchased_by_guest_name %}
Name of the guest purchaser.
{% enddocs %}

{% docs purchased_by_user_id %}
ID of the user who made the purchase.
{% enddocs %}

{% docs quantity %}
Quantity for the line item or subscription item.
{% enddocs %}

{% docs recurring_inverval %}
Recurring interval for the price.
{% enddocs %}

{% docs redeem_by_datetime %}
Datetime by which the coupon must be redeemed.
{% enddocs %}

{% docs redeemed_by_user_id %}
ID of the user who redeemed the gift card.
{% enddocs %}

{% docs record_created_datetime %}
Timestamp when the record was created.
{% enddocs %}

{% docs refunded_amt %}
Refunded amount (in dollars).
{% enddocs %}

{% docs refunded_flag %}
Flag indicating if the charge was refunded.
{% enddocs %}

{% docs remaining_amt %}
Amount remaining (in dollars).
{% enddocs %}

{% docs row_level_security_id %}
Row-level security identifier.
{% enddocs %}

{% docs row_num %}
Row number for ordering.
{% enddocs %}

{% docs rfid %}
RFID value.
{% enddocs %}

{% docs signup_closest_location_id %}
Closest location ID at signup.
{% enddocs %}

{% docs signup_created_by_user_id %}
User ID who created the signup.
{% enddocs %}

{% docs signup_unique_tenant_location_id %}
Unique tenant-location ID for the signup.
{% enddocs %}

{% docs signup_zip_code %}
ZIP code at signup.
{% enddocs %}

{% docs state %}
State of the location.
{% enddocs %}

{% docs status %}
Status of the charge, invoice, or subscription.
{% enddocs %}

{% docs status_current %}
Current status.
{% enddocs %}

{% docs status_previous %}
Previous status.
{% enddocs %}

{% docs stored_wash_source %}
Source of the stored wash.
{% enddocs %}

{% docs street1 %}
Primary street address.
{% enddocs %}

{% docs street2 %}
Secondary street address.
{% enddocs %}

{% docs stripe_customer_id %}
Stripe ID of the customer.
{% enddocs %}

{% docs stripe_discount_id %}
Unique identifier for the Stripe discount.
{% enddocs %}

{% docs stripe_price_id %}
Unique identifier for the Stripe price.
{% enddocs %}

{% docs stripe_product_id %}
Unique identifier for the Stripe product.
{% enddocs %}

{% docs stripe_subscription_history_id %}
Unique identifier for the subscription history record.
{% enddocs %}

{% docs stripe_subscription_id %}
Stripe subscription ID associated with the account.
{% enddocs %}

{% docs subscription_cancellation_external_id %}
External ID for the subscription cancellation.
{% enddocs %}

{% docs subscription_id %}
ID of the related subscription.
{% enddocs %}

{% docs subscription_item_id %}
ID of the related subscription item.
{% enddocs %}

{% docs subscription_location_id %}
ID of the subscription location.
{% enddocs %}

{% docs subscription_status %}
Status of the subscription.
{% enddocs %}

{% docs subscription_unique_tenant_location_id %}
Unique tenant-location ID for the subscription.
{% enddocs %}

{% docs tax_amt %}
Tax amount (in dollars).
{% enddocs %}

{% docs tax_inclusive_flag %}
Flag indicating if the tax is inclusive.
{% enddocs %}

{% docs tax_jurisdiction %}
Tax jurisdiction for the line item.
{% enddocs %}

{% docs tax_location_override_id %}
Tax location override ID.
{% enddocs %}

{% docs tax_rate %}
Tax rate for the subscription or line item.
{% enddocs %}

{% docs tenant_id %}
External identifier for the tenant.
{% enddocs %}

{% docs tier1_amt %}
Tier 1 price amount.
{% enddocs %}

{% docs tier2_amt %}
Tier 2 price amount.
{% enddocs %}

{% docs tier3_amt %}
Tier 3 price amount.
{% enddocs %}

{% docs tier4_amt %}
Tier 4 price amount.
{% enddocs %}

{% docs total_amt %}
Total amount of the invoice (in dollars).
{% enddocs %}

{% docs transfer_date %}
Date when the vehicle was transferred.
{% enddocs %}

{% docs transfer_datetime %}
Datetime when the vehicle was transferred.
{% enddocs %}

{% docs type %}
Type of the line item or event.
{% enddocs %}

{% docs user_id %}
ID of the user.
{% enddocs %}

{% docs value_amt %}
Value of the gift card promotion (in dollars).
{% enddocs %}

{% docs vehicle_history_id %}
Unique identifier for the vehicle history record.
{% enddocs %}

{% docs vehicle_id %}
ID of the vehicle.
{% enddocs %}

{% docs vehicle_rfid_id %}
Unique identifier for the vehicle RFID record.
{% enddocs %}

{% docs vif_id %}
VIF ID.
{% enddocs %}

{% docs vin %}
Vehicle Identification Number.
{% enddocs %}

{% docs voided_at_date %}
Date when the invoice was voided.
{% enddocs %}

{% docs zip_code %}
ZIP code of the location or user.
{% enddocs %}

{% docs account_type %}
Type of the account.
{% enddocs %}

{% docs transaction_type_id %}
Type of the transaction.
{% enddocs %}

{% docs mobile_user_activity_id %}
Unique identifier for the mobile user activity record.
{% enddocs %}

{% docs autowash_location_id %}
ID of the location where the activity occurred.
{% enddocs %}

{% docs duration %}
Duration of the coupon.
{% enddocs %}

{% docs duration_in_months %}
Duration in months.
{% enddocs %}

{% docs max_redemptions %}
Maximum number of times the coupon can be redeemed.
{% enddocs %}

{% docs refund_flag %}
Flag indicating if the transaction was refunded.
{% enddocs %}

{% docs LOCATION_ID %}
Unique identifier for each location.
{% enddocs %}

{% docs TENANT_ID %}
External identifier for the tenant to which the location belongs.
{% enddocs %}

{% docs LOCATION_NAME %}
Human-readable name of the location.
{% enddocs %}

{% docs LOCATION_INTERNAL_NAME %}
Internal system name used for identifying the location.
{% enddocs %}

{% docs LOCATION_IS_FRANCHISE %}
Boolean flag indicating if the location is a franchise.
{% enddocs %}

{% docs TEST_LOCATION %}
Boolean flag indicating if the location is a test/demo location.
{% enddocs %}

{% docs LOCATION_CODE %}
Short internal code used for location identification.
{% enddocs %}

{% docs LOCATION_STREET1 %}
Primary street address of the location.
{% enddocs %}

{% docs LOCATION_STREET2 %}
Secondary address line, if available.
{% enddocs %}

{% docs LOCATION_CITY %}
City where the location is situated.
{% enddocs %}

{% docs LOCATION_STATE %}
State or region of the location.
{% enddocs %}

{% docs LOCATION_ZIP_CODE %}
Postal ZIP code of the location.
{% enddocs %}

{% docs LOCATION_IMAGE_URL %}
Image URL or visual representation of the location.
{% enddocs %}

{% docs LOCATION_CREATED_DATETIME %}
Timestamp when the location record was first created.
{% enddocs %}

{% docs ROW_LEVEL_SECURITY_ID %}
Identifier used for enforcing row-level security by tenant or hierarchy.
{% enddocs %}

{% docs pause_request_date %}
Date when pause was requested.
{% enddocs %}

{% docs pause_effective_date %}
Date when pause is effective.
{% enddocs %}

{% docs pause_end_date %}
Date when pause ends.
{% enddocs %}

{% docs vehicle_make %}
Make of the vehicle.
{% enddocs %}

{% docs vehicle_model %}
Model of the vehicle.
{% enddocs %}

{% docs vehicle_year %}
Year of the vehicle.
{% enddocs %}

{% docs vehicle_color %}
Color of the vehicle.
{% enddocs %}

{% docs rfid_tag_number %}
RFID tag number assigned to the vehicle.
{% enddocs %}

{% docs rfid_tag_status %}
Status of the RFID tag.
{% enddocs %}

{% docs rfid_tag_type %}
Type of the RFID tag.
{% enddocs %}

{% docs rfid_tag_location_id %}
Location ID where the RFID tag was assigned.
{% enddocs %}

{% docs rfid_tag_unique_tenant_location_id %}
Unique tenant-location ID for the RFID tag assignment.
{% enddocs %}

{% docs stripe_subscription_item_history_id %}
Unique identifier for the subscription item history record.
{% enddocs %}

{% docs cancellation_reason %}
Reason for cancellation.
{% enddocs %}

{% docs cancellation_reason_category %}
Category of the cancellation reason.
{% enddocs %}

{% docs cancellation_reason_subcategory %}
Subcategory of the cancellation reason.
{% enddocs %}

{% docs cancellation_reason_details %}
Detailed description of the cancellation reason.
{% enddocs %}

{% docs cancellation_reason_other_details %}
Additional details for other cancellation reasons.
{% enddocs %}

{% docs cancellation_reason_source %}
Source of the cancellation reason.
{% enddocs %}

{% docs cancellation_reason_source_details %}
Detailed description of the cancellation reason source.
{% enddocs %}

{% docs cancellation_reason_source_other_details %}
Additional details for other cancellation reason sources.
{% enddocs %}

{% docs cancellation_reason_source_category %}
Category of the cancellation reason source.
{% enddocs %}

{% docs cancellation_reason_source_subcategory %}
Subcategory of the cancellation reason source.
{% enddocs %}

{% docs override_location_id %}
Override location ID.
{% enddocs %}

{% docs override_unique_tenant_location_id %}
Unique tenant-location ID for the override.
{% enddocs %}

{% docs pending_downgrade_date %}
Date when downgrade is pending.
{% enddocs %}

{% docs subscription_created_datetime %}
Timestamp when the subscription was created.
{% enddocs %}

{% docs cancel_at_period_end_previous_flag %}
Flag for previous cancel at period end.
{% enddocs %}

{% docs cancel_at_period_end_current_falg %}
Flag for current cancel at period end.
{% enddocs %}

{% docs billing_cycle_anchor_previous_date %}
Previous billing cycle anchor date.
{% enddocs %}

{% docs billing_cycle_anchor_current_date %}
Current billing cycle anchor date.
{% enddocs %}

{% docs cancel_at_previous_date %}
Previous cancel at date.
{% enddocs %}

{% docs cancel_at_current_date %}
Current cancel at date.
{% enddocs %}

{% docs canceled_at_previous_date %}
Previous canceled at date.
{% enddocs %}

{% docs canceled_at_current_date %}
Current canceled at date.
{% enddocs %}

{% docs tax_rate_previous %}
Previous tax rate.
{% enddocs %}

{% docs tax_rate_current %}
Current tax rate.
{% enddocs %}

{% docs downgrade_price_id_previous %}
Previous downgrade price ID.
{% enddocs %}

{% docs downgrade_price_id_current %}
Current downgrade price ID.
{% enddocs %}

{% docs downgrade_expiration_previous_date %}
Previous downgrade expiration date.
{% enddocs %}

{% docs downgrade_expiration_current_date %}
Current downgrade expiration date.
{% enddocs %}

{% docs auto_cancel_date_current_date %}
Current auto cancel date.
{% enddocs %}

{% docs auto_cancel_date_previous_date %}
Previous auto cancel date.
{% enddocs %}

{% docs pause_request_date_previous_date %}
Previous pause request date.
{% enddocs %}

{% docs pause_effective_date_previous_date %}
Previous pause effective date.
{% enddocs %}

{% docs pause_end_date_previous_date %}
Previous pause end date.
{% enddocs %}

{% docs cancellation_details_reason_previous %}
Previous cancellation reason.
{% enddocs %}

{% docs aaa_membership_number_previous %}
Previous AAA membership number.
{% enddocs %}

{% docs price_id_previous %}
Previous price ID.
{% enddocs %}

{% docs price_id_current %}
Current price ID.
{% enddocs %}

{% docs quantity_previous %}
Previous quantity.
{% enddocs %}

{% docs quantity_current %}
Current quantity.
{% enddocs %}

{% docs license_plate_number_previous %}
Previous license plate number.
{% enddocs %}

{% docs license_plate_number_current %}
Current license plate number.
{% enddocs %}

{% docs license_plate_state_previous %}
Previous license plate state.
{% enddocs %}

{% docs license_plate_state_current %}
Current license plate state.
{% enddocs %}

{% docs vehicle_make_previous %}
Previous vehicle make.
{% enddocs %}

{% docs vehicle_make_current %}
Current vehicle make.
{% enddocs %}

{% docs vehicle_model_previous %}
Previous vehicle model.
{% enddocs %}

{% docs vehicle_model_current %}
Current vehicle model.
{% enddocs %}

{% docs vehicle_year_previous %}
Previous vehicle year.
{% enddocs %}

{% docs vehicle_year_current %}
Current vehicle year.
{% enddocs %}

{% docs vehicle_color_previous %}
Previous vehicle color.
{% enddocs %}

{% docs vehicle_color_current %}
Current vehicle color.
{% enddocs %}

---

## Intermediate Models

{% docs int_subscription_cancellations_vw %}
Intermediate model that provides the latest cancellation details for each subscription, including reason codes, user information, and pre-cancellation status.
{% enddocs %}

{% docs int_subscription_first_invoice_vw %}
Intermediate model that captures the first paid invoice for each subscription, including amounts and creation dates.
{% enddocs %}

{% docs int_subscription_invoice_count_vw %}
Intermediate model that counts the total number of paid invoices for each subscription.
{% enddocs %}

{% docs int_subscription_last_charge_failure_vw %}
Intermediate model that provides details about the most recent failed charge attempt for each subscription.
{% enddocs %}

{% docs int_subscription_vehicle_tracking_vw %}
Intermediate model that tracks vehicle information for subscriptions, including license plate history, RFID tags, and legacy reactivation status.
{% enddocs %}

{% docs int_subscription_wash_locations_vw %}
Intermediate model that tracks the first and last wash locations for each subscription based on mobile user activity.
{% enddocs %}

---

## Intermediate Column Docs

{% docs cancellation_reason_picklist_id %}
ID of the picklist value representing the cancellation reason.
{% enddocs %}

{% docs cancellation_reason_text %}
Text description of the cancellation reason from the picklist.
{% enddocs %}

{% docs canceled_user_id %}
ID of the user who canceled the subscription.
{% enddocs %}

{% docs status_pre_cancel %}
Subscription status before it was canceled.
{% enddocs %}

{% docs first_invoice_subtotal_amt %}
Subtotal amount of the first invoice.
{% enddocs %}

{% docs first_invoice_discount_amt %}
Discount amount applied to the first invoice.
{% enddocs %}

{% docs first_invoice_amt %}
Net amount of the first invoice after discounts.
{% enddocs %}

{% docs first_invoice_created_date %}
Date when the first invoice was created.
{% enddocs %}

{% docs number_of_paid_invoices_to_date %}
Total count of paid invoices for the subscription.
{% enddocs %}

{% docs last_charge_failure_message %}
Error message from the most recent failed charge attempt.
{% enddocs %}

{% docs last_charge_failure_code %}
Error code from the most recent failed charge attempt.
{% enddocs %}

{% docs last_charge_failure_card_funding %}
Funding type of the card used in the most recent failed charge attempt.
{% enddocs %}

{% docs first_subscription_id_for_plate %}
ID of the first subscription associated with a license plate.
{% enddocs %}

{% docs is_legacy_reactivation %}
Flag indicating if the subscription is a reactivation of a legacy subscription.
{% enddocs %}

{% docs most_recent_rfid %}
Most recent RFID tag assigned to the vehicle.
{% enddocs %}

{% docs first_wash_location_id %}
ID of the location where the subscription's first wash occurred.
{% enddocs %}

{% docs last_wash_location_id %}
ID of the location where the subscription's most recent wash occurred.
{% enddocs %}

{% docs failure_code %}
Error code associated with a failed transaction or operation.
{% enddocs %}

{% docs payment_method_details_card_funding %}
Funding type of the payment card (credit, debit, prepaid, etc.).
{% enddocs %}

{% docs mobile_user_activity_id %}
Unique identifier for a mobile user activity record.
{% enddocs %}

{% docs first_invoice_created_datetime %}
Timestamp when the first invoice was created.
{% enddocs %}

{% docs subtotal_amt %}
Subtotal amount before discounts and taxes.
{% enddocs %}

{% docs discount_amt %}
Discount amount applied to the transaction.
{% enddocs %}

{% docs billing_cycle_anchor_date %}
Date that determines the billing cycle schedule.
{% enddocs %}

{% docs billing_reason %}
Reason for generating the invoice or billing event.
{% enddocs %}

{% docs charge_created_datetime %}
Timestamp when the charge was created.
{% enddocs %}

{% docs failure_message %}
Detailed message explaining the reason for a failure.
{% enddocs %}

{% docs payment_method_id %}
Identifier for the payment method used.
{% enddocs %}

{% docs rfid %}
RFID tag identifier.
{% enddocs %}

{% docs vehicle_history_id %}
Unique identifier for a vehicle history record.
{% enddocs %} 