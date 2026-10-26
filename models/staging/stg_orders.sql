WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_orders') }}
),

cleaned AS (
    SELECT
        order_id,
        customer_id,
        -- lowercase + trim so 'Delivered' and 'delivered ' can't split a group
        LOWER(TRIM(order_status)) AS order_status,
        -- timestamps are already TIMESTAMP in Bronze; only renaming here
        order_purchase_timestamp AS ordered_at,
        order_approved_at AS approved_at,
        order_delivered_carrier_date AS shipped_at,
        order_delivered_customer_date AS delivered_at,
        order_estimated_delivery_date AS estimated_delivery_at
    FROM source
)

SELECT
    *,
    -- was the order delivered?
    order_status = 'delivered' AS is_delivered,
    -- delivered on or before the estimate? NULL when not delivered yet
    CASE
        WHEN delivered_at IS NULL OR estimated_delivery_at IS NULL THEN NULL
        ELSE delivered_at <= estimated_delivery_at
    END AS is_on_time
FROM cleaned