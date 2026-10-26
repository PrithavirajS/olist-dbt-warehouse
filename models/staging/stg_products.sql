-- Silver layer: one clean row per product, with English category names.
-- Source: bronze_olist.raw_products + stg_category_translation

WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_products') }}
),

translation AS (
    SELECT * FROM {{ ref('stg_category_translation') }}
),

cleaned AS (
    SELECT
        s.product_id,
        LOWER(TRIM(s.product_category_name)) AS category_name_pt,
        COALESCE(t.category_name_en, LOWER(TRIM(s.product_category_name)), 'unknown') AS category_name_en,
        s.product_name_lenght AS name_length,
        s.product_description_lenght AS description_length,
        s.product_photos_qty AS photos_qty,
        s.product_weight_g AS weight_g,
        s.product_length_cm AS length_cm,
        s.product_height_cm AS height_cm,
        s.product_width_cm AS width_cm
    FROM source AS s
    LEFT JOIN translation AS t
    ON LOWER(TRIM(s.product_category_name)) = t.category_name_pt

)

SELECT
    *,
    length_cm * height_cm * width_cm AS volume_cm3
FROM cleaned