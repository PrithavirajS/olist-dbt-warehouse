-- Gold layer: share of customers (real people) who ordered more than once.
-- Grain: a single row for the whole business.
-- Uses customer_unique_id, NOT customer_id (which changes with every order).

WITH orders_per_customer AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM {{ ref('int_orders_enriched') }}
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    COUNTIF(order_count > 1) AS repeat_customers,
    SAFE_DIVIDE(COUNTIF(order_count > 1), COUNT(*)) AS repeat_rate
FROM orders_per_customer