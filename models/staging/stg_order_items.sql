-- Silver layer: one clean row per item within an order.
-- Natural key = order_id + item_sequence (combined into order_item_key).
-- Source: bronze_olist.raw_order_items

WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_order_items') }}
),

cleaned AS (
    SELECT
        CONCAT(order_id, '-', CAST(order_item_id AS STRING)) AS order_item_key,
        order_id,
        order_item_id AS item_sequence,
        product_id,
        seller_id,
        shipping_limit_date AS shipping_limit_at,
        price,
        freight_value
    FROM source
)

SELECT
    *,
    price + freight_value AS item_total
FROM cleaned