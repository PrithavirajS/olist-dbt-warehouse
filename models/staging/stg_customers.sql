-- Silver layer: one clean row per customer record (one per order).
-- customer_id = joins to orders (new value for every order)
-- customer_unique_id = the real person (use this for repeat-rate and LTV)
-- Source: bronze_olist.raw_customers

WITH source AS (
    SELECT * FROM {{ source('olist', 'raw_customers') }}
),

cleaned AS (
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix AS zip_code_prefix,
        LOWER(TRIM(customer_city)) AS city,
        UPPER(TRIM(customer_state)) As state
    FROM source
)

SELECT * FROM cleaned