-- Silver layer: one row per zip code prefix (raw table has ~1M duplicate-ish rows).
-- Joining customers/sellers to the raw table would multiply rows, so we collapse here.
-- Source: bronze_olist.raw_geolocation

WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_geolocation') }}
),

collapsed AS (
    SELECT
        geolocation_zip_code_prefix AS zip_code_prefix,
        AVG(geolocation_lat) AS latitude,
        AVG(geolocation_lng) AS longitude,
        APPROX_TOP_COUNT(LOWER(TRIM(geolocation_city)), 1)[OFFSET(0)].value AS city,
        APPROX_TOP_COUNT(UPPER(TRIM(geolocation_state)), 1)[OFFSET(0)].value AS state,
        COUNT(*) AS raw_row_count
    FROM source
    GROUP BY geolocation_zip_code_prefix
)

SELECT * FROM collapsed