{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            tenant__r__external_id__c,
            invoice_id,
            deleted,
            customer_id,
            payment_id,
            subscription_id,
            status,
            total,
            discount,
            subtotal,
            tax_rate,
            tax,
            amount_paid,
            amount_due,
            amount_remaining,
            attempt_count,
            billing_reason,
            post_payment_credit_notes_amount,
            pre_payment_credit_notes_amount,
            period_start,
            period_end,
            invoice_created,
            created,
            last_modified,
            hosted_invoice_url,
            invoice_pdf,
            app_id,
            is_gift_card,
            tax_inclusive,
            location_id,
            created_by_admin_id,
            kiosk_id,
            invoice_type,
            paid_out_of_band,
            checkout_id,
            wash_type_id,
            prepaid_wash_promotion_id,
            price_group_id,
            promo_code_id,
            coupon_id,
            paid_at,
            marked_uncollectible_at,
            voided_at,
            finalized_at,
            collection_method,
            aaa_membership_number,
            account_id
        FROM {{ source('REPORTING','STRIPE_INVOICES') }}
    ),

    renamed_cte AS (
        SELECT
            tenant__r__external_id__c                AS tenant_id,
            invoice_id,
            deleted                                  AS deleted_flag,
            customer_id                              AS stripe_customer_id,
            payment_id,
            subscription_id,
            status,

            -- total                                    AS total_cents,
            total / 100.0                            AS total_amt,

            -- discount                                 AS discount_cents,
            discount / 100.0                         AS discount_amt,

            -- subtotal                                 AS subtotal_cents,
            subtotal / 100.0                         AS subtotal_amt,

            tax_rate,

            -- tax                                      AS tax_cents,
            tax / 100.0                              AS tax_amt,

            -- amount_paid                              AS amount_paid_cents,
            amount_paid / 100.0                      AS paid_amt,

            -- amount_due                               AS amount_due_cents,
            amount_due / 100.0                       AS due_amt,

            -- amount_remaining                         AS amount_remaining_cents,
            amount_remaining / 100.0                 AS remaining_amt,

            attempt_count,
            billing_reason,

            -- post_payment_credit_notes_amount         AS post_payment_credit_notes_cents,
            post_payment_credit_notes_amount / 100.0 AS post_payment_credit_notes_amt,

            -- pre_payment_credit_notes_amount          AS pre_payment_credit_notes_amount_cents,
            pre_payment_credit_notes_amount / 100.0  AS pre_payment_credit_notes_amt,

            -- period_start                             AS period_start_datetime,
            cast(period_start AS date)               AS period_start_date,

            -- period_end                               AS period_end_datetime,
            cast(period_end AS date)                 AS period_end_date,

            invoice_created                          AS invoice_created_datetime,
            cast(invoice_created AS date)            AS invoice_created_date,

            created                                  AS record_created_datetime,
            cast(created AS date)                    AS record_created_date,

            hosted_invoice_url,
            invoice_pdf                              AS invoice_pdf_url,
            app_id,

            is_gift_card                             AS is_gift_card_flag,
            tax_inclusive                            AS tax_inclusive_flag,

            location_id,
            created_by_admin_id                      AS created_by_admin_user_id,
            kiosk_id,
            invoice_type,

            paid_out_of_band                         AS paid_out_of_band_flag,

            checkout_id,
            wash_type_id,
            prepaid_wash_promotion_id,
            price_group_id,
            promo_code_id,
            coupon_id,

            paid_at                                  AS paid_at_datetime,
            cast(paid_at AS date)                    AS paid_at_date,

            -- marked_uncollectible_at                  AS marked_uncollectible_at_datetime,
            cast(marked_uncollectible_at AS date)    AS marked_uncollectible_at_date,

            -- voided_at                                AS voided_at_datetime,
            cast(voided_at AS date)                  AS voided_at_date,

            finalized_at                             AS finalized_at_datetime,
            cast(finalized_at AS date)               AS finalized_at_date,

            collection_method,
            aaa_membership_number,
            account_id,
            last_modified                            AS last_modified_datetime,
            cast(last_modified AS date)              AS last_modified_date,
        FROM source_cte
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
