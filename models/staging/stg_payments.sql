-- Silver layer: one clean row per payment (an order can have several).
-- Natural key = order_id + payment_sequence (combined into payment_key).
-- Source: bronze_olist.raw_payments

WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_payments') }}
),

cleaned AS (
    SELECT
        CONCAT(order_id, '-', CAST(payment_sequential AS STRING)) AS payment_key,
        order_id,
        payment_sequential AS payment_sequence,
        LOWER(TRIM(payment_type)) AS payment_type,
        payment_installments AS installments,
        payment_value AS payment_amount
    FROM source
)

SELECT * FROM cleaned