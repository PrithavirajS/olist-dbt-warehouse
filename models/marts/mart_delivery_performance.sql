-- Gold layer: delivery performance by seller and customer state.
-- Grain: one row per seller_id + customer_state.
-- Only delivered orders with both timestamps are included.

WITH seller_orders AS (
    SELECT DISTINCT
        order_id,
        seller_id
    FROM {{ ref('stg_order_items') }}
),

delivered AS (
    SELECT
        so.seller_id,
        o.customer_state,
        o.order_id,
        TIMESTAMP_DIFF(o.delivered_at, o.ordered_at, HOUR) / 24.0 AS actual_days,
        TIMESTAMP_DIFF(o.estimated_delivery_at, o.ordered_at, HOUR) / 24.0  AS estimated_days,
        o.is_on_time
    FROM seller_orders AS so
    INNER JOIN {{ ref('int_orders_enriched') }} AS o
        ON so.order_id = o.order_id
    WHERE
        o.is_delivered
        AND o.delivered_at IS NOT NULL
        AND o.estimated_delivery_at IS NOT NULL
)

SELECT
    seller_id,
    customer_state,
    COUNT(*) AS delivered_orders,
    AVG(actual_days) AS avg_actual_days,
    AVG(estimated_days) AS avg_estimated_days,
    AVG(estimated_days - actual_days) AS avg_days_early,
    AVG(CAST(is_on_time AS int64)) AS on_time_rate
FROM delivered
GROUP BY seller_id, customer_state