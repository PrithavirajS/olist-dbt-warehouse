-- Gold layer: daily revenue by customer state.
-- Grain: one row per order_date + customer_state.
-- Canceled and unavailable orders are excluded from revenue.

SELECT
    order_date,
    customer_state,
    COUNT(*) AS order_count,
    SUM(items_revenue) AS items_revenue,
    SUM(freight_revenue) AS freight_revenue,
    SUM(order_revenue) AS total_revenue,
    SAFE_DIVIDE(SUM(order_revenue), COUNT(*)) AS avg_order_value
FROM {{ ref('int_orders_enriched') }}
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY order_date, customer_state