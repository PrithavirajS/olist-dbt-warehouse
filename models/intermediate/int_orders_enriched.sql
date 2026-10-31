-- Intermediate layer: one wide row per order, ready for the marts.
-- Items and payments are aggregated to ONE row per order BEFORE joining,
-- so the joins can never multiply rows (fan-out).
-- Sources: stg_orders, stg_customers, stg_order_items, stg_payments

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

items_per_order AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        COUNT(DISTINCT product_id) AS distinct_products,
        COUNT(DISTINCT seller_id) AS distinct_sellers,
        SUM(price) AS items_revenue,
        SUM(freight_value) AS freight_revenue
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),

payments_per_order AS (
    SELECT
        order_id,
        COUNT(*) AS payment_count,
        SUM(payment_amount) AS payment_total
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
),

joined AS (
    SELECT
        o.order_id,
        o.customer_id,
        c.customer_unique_id,
        c.city AS customer_city,
        c.state AS customer_state,
        o.order_status,
        o.ordered_at,
        o.approved_at,
        o.shipped_at,
        o.delivered_at,
        o.estimated_delivery_at,
        o.is_delivered,
        o.is_on_time,
        COALESCE(i.item_count, 0) AS item_count,
        COALESCE(i.distinct_products, 0) AS distinct_products,
        COALESCE(i.distinct_sellers, 0) AS distinct_sellers,
        COALESCE(i.items_revenue, 0) AS items_revenue,
        COALESCE(i.freight_revenue, 0) AS freight_revenue,
        COALESCE(p.payment_count, 0) AS payment_count,
        COALESCE(p.payment_total, 0) AS payment_total
    FROM orders AS o
    LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
    LEFT JOIN items_per_order AS i
    ON o.order_id = i.order_id
    LEFT JOIN payments_per_order AS p
    ON o.order_id = p.order_id
)

SELECT
    *,
    items_revenue + freight_revenue AS order_revenue,
    DATE(ordered_at) AS order_date
FROM joined