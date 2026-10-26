-- Silver layer: Portuguese-to-English product category lookup (71 rows).
-- Source: bronze_olist.raw_category_translation

WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_category_translation') }}
),

cleaned AS (
    SELECT
        LOWER(TRIM(product_category_name)) AS category_name_pt,
        LOWER(TRIM(product_category_name_english)) AS category_name_en
    FROM source
)

SELECT * FROM cleaned