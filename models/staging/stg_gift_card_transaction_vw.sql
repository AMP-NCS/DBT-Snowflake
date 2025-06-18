{{ config(materialized='view') }}

WITH
    source_cte AS (
        SELECT
            id,
            tenant__r__external_id__c,
            created,
            created_by_id,
            last_modified,
            last_modified_by_id,
            gift_card_id,
            request_source_id,
            transaction_type_id,
            amount_in_cents,
            user_id,
            comment
        FROM {{ source('GENERAL','GIFT_CARD_TRANSACTION') }}
    ),

    renamed_cte AS (
        SELECT
            id                                             AS gift_card_transaction_id,
            tenant__r__external_id__c                      AS tenant_id,
            created                                        AS created_datetime,
            cast(created AS date)                          AS created_date,
            created_by_id                                  AS created_by_user_id,
            last_modified                                  AS last_modified_datetime,
            cast(last_modified AS date)                    AS last_modified_date,
            last_modified_by_id                            AS last_modified_by_user_id,
            gift_card_id,
            request_source_id,
            transaction_type_id,
            -- amount_in_cents                                AS gift_card_transaction_cents,
            cast(amount_in_cents / 100.0 AS decimal(9, 2)) AS gift_card_transaction_amt,
            user_id,
            comment
        FROM source_cte
    ),

    final_cte AS (
        SELECT * FROM renamed_cte
    )

SELECT * FROM final_cte
