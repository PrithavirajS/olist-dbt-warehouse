# ── imports ──────────────────────────────────────────────
from google.cloud import bigquery
import os

# ── credentials ──────────────────────────────────────────
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"E:\dbt-service-account.json"

client = bigquery.Client(project="olist-dbt-warehouse")

# ── all files except reviews ──────────────────────────────
files = {
    "olist_orders_dataset.csv":              "raw_orders",
    "olist_customers_dataset.csv":           "raw_customers",
    "olist_order_items_dataset.csv":         "raw_order_items",
    "olist_order_payments_dataset.csv":      "raw_payments",
    "olist_products_dataset.csv":            "raw_products",
    "olist_sellers_dataset.csv":             "raw_sellers",
    "olist_geolocation_dataset.csv":         "raw_geolocation",
    "product_category_name_translation.csv": "raw_category_translation",
}

reviews_file = "olist_order_reviews_dataset.csv"

for filename, table_name in files.items():
    table_id = f"olist-dbt-warehouse.bronze_olist.{table_name}"
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        autodetect=True,
        write_disposition="WRITE_TRUNCATE",
    )
    with open(f"seeds/raw_data/{filename}", "rb") as f:
        job = client.load_table_from_file(f, table_id, job_config=job_config)
        job.result()
    print(f"✅ Loaded {filename} → {table_name}")

# ── reviews (special config for messy text) ───────────────
table_id = f"olist-dbt-warehouse.bronze_olist.raw_reviews"
job_config = bigquery.LoadJobConfig(
    source_format=bigquery.SourceFormat.CSV,
    skip_leading_rows=1,
    autodetect=True,
    write_disposition="WRITE_TRUNCATE",
    allow_quoted_newlines=True,
    allow_jagged_rows=True,
    max_bad_records=1000,
    encoding="UTF-8",
)
with open(f"seeds/raw_data/{reviews_file}", "rb") as f:
    job = client.load_table_from_file(f, table_id, job_config=job_config)
    job.result()
print(f"✅ Loaded {reviews_file} → raw_reviews")

print("\n🎉 All 9 tables loaded into bronze_olist!")