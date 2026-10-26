-- Silver layer: one clean row per seller.
-- Source: bronze_olist.raw_sellers

WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_sellers') }}
),

cleaned AS (
    SELECT
        seller_id,
        seller_zip_code_prefix AS zip_code_prefix,
        LOWER(TRIM(seller_city)) AS city,
        UPPER(TRIM(seller_state)) AS state
    FROM source
)

SELECT * FROM cleaned