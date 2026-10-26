-- Silver layer: one clean row per review-order pair.
-- review_id alone is NOT unique in the raw data, so the key is review_id + order_id.
-- Source: bronze_olist.raw_reviews

WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_reviews') }}
),

cleaned AS (
    SELECT
        CONCAT(review_id, '-', order_id) AS review_key,
        review_id,
        order_id,
        review_score,
        NULLIF(TRIM(REGEXP_REPLACE(review_comment_title, r'[\r\n]+', ' ')), '') AS comment_title,
        NULLIF(TRIM(REGEXP_REPLACE(review_comment_message, r'[\r\n]+', ' ')), '')  AS comment_message,
        review_creation_date AS created_at,
        review_answer_timestamp AS answered_at
    FROM source
),

deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY review_key ORDER BY answered_at DESC) AS row_num
    FROM cleaned
)

SELECT
    * EXCEPT (row_num),
    comment_message IS NOT NULL AS has_comment
FROM deduplicated
WHERE row_num = 1