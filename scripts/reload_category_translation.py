from pathlib import Path

from google.cloud import bigquery
from google.oauth2 import service_account

# ---------- Edit these two lines ----------
KEYFILE = "E:/dbt-service-account.json"
PROJECT_ID = "olist-dbt-warehouse"
# ------------------------------------------

CSV_PATH = (
    Path(__file__).resolve().parent.parent
    / "raw_data"
    / "product_category_name_translation.csv"
)
TABLE_ID = f"{PROJECT_ID}.bronze_olist.raw_category_translation"

credentials = service_account.Credentials.from_service_account_file(KEYFILE)
client = bigquery.Client(project=PROJECT_ID, credentials=credentials, location="US")

config = bigquery.LoadJobConfig(
    source_format=bigquery.SourceFormat.CSV,
    skip_leading_rows=1,
    schema=[
        bigquery.SchemaField("product_category_name", "STRING"),
        bigquery.SchemaField("product_category_name_english", "STRING"),
    ],
    write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    encoding="UTF-8",
)

with open(CSV_PATH, "rb") as f:
    job = client.load_table_from_file(f, TABLE_ID, job_config=config)
job.result()

print(f"Loaded {client.get_table(TABLE_ID).num_rows} rows into {TABLE_ID}")