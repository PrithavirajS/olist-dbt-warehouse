-- Gold layer: one row per seller with revenue, orders and review score.
-- Reviews are averaged per order first so multi-review orders are not over-weighted.

WITH valid_orders AS (
    SELECT order_id
    FROM {{ ref('stg_orders') }}
    WHERE order_status NOT IN ('canceled', 'unavailable')
),

seller_orders AS (
    SELECT
        i.seller_id,
        i.order_id,
        SUM(i.price) AS seller_order_revenue
    FROM {{ ref('stg_order_items') }} AS i
    INNER JOIN valid_orders AS v
        ON i.order_id = v.order_id
    GROUP BY i.seller_id, i.order_id
),

reviews_per_order AS (
    SELECT
        order_id,
        AVG(review_score) AS order_review_score
    FROM {{ ref('stg_reviews') }}
    GROUP BY order_id
),

scored AS (
    SELECT
        so.seller_id,
        so.order_id,
        so.seller_order_revenue,
        r.order_review_score
    FROM seller_orders AS so
    LEFT JOIN reviews_per_order AS r
        ON so.order_id = r.order_id
)

SELECT
    s.seller_id,
    sel.city AS seller_city,
    sel.state AS seller_state,
    COUNT(*) AS order_count,
    SUM(s.seller_order_revenue) AS total_revenue,
    AVG(s.order_review_score) AS avg_review_score
FROM scored AS s
LEFT JOIN {{ ref('stg_sellers') }} AS sel
    ON s.seller_id = sel.seller_id
GROUP BY s.seller_id, sel.city, sel.state