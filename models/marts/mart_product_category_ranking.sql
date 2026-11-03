-- Gold layer: revenue, units and average price per product category.
-- Grain: one row per category_name_en.

WITH valid_orders AS (
    SELECT order_id
    FROM {{ ref('stg_orders') }}
    WHERE order_status NOT IN ('canceled', 'unavailable')
),

category_sales AS (
    SELECT
        p.category_name_en,
        COUNT(*) AS units_sold,
        COUNT(DISTINCT i.order_id) AS order_count,
        SUM(i.price) AS total_revenue,
        AVG(i.price) AS avg_price
    FROM {{ ref('stg_order_items') }} AS i
    INNER JOIN valid_orders AS v
        ON i.order_id = v.order_id
    LEFT JOIN {{ ref('stg_products') }} AS p
        ON i.product_id = p.product_id
    GROUP BY p.category_name_en
)

SELECT
    *,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_sales