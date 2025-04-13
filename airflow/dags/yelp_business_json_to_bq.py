from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.utils.dates import days_ago
from datetime import timedelta
import pandas as pd
import json
import os

# Config
BUCKET_NAME = "yelp_gcp_bucket"
RAW_JSON_BLOB = "yelp_academic_dataset_business.json"
CLEAN_CSV_FILE = "/tmp/yelp_business_clean.csv"
CLEAN_CSV_BLOB = "yelp_business_clean.csv"
GCP_PROJECT = "yelpdatapipeline"
BQ_DATASET = "yelp_dataset"
BQ_TABLE = "business"

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "email_on_failure": False,
    "email_on_retry": False,
}

def convert_json_to_cleaned_csv():
    hook = GCSHook(gcp_conn_id="google_cloud_default")
    raw_bytes = hook.download(bucket_name=BUCKET_NAME, object_name=RAW_JSON_BLOB)
    raw_str = raw_bytes.decode("utf-8").splitlines()
    data = [json.loads(line) for line in raw_str]
    df = pd.json_normalize(data)
    df.columns = df.columns.str.replace(".", "_")  # Replace dots in column names
    df.to_csv(CLEAN_CSV_FILE, index=False)
    hook.upload(bucket_name=BUCKET_NAME, object_name=CLEAN_CSV_BLOB, filename=CLEAN_CSV_FILE)
    os.remove(CLEAN_CSV_FILE)  # Clean up

with DAG(
    dag_id="yelp_business_json_to_bq_pipeline",
    default_args=default_args,
    description="Convert business JSON to CSV and load into BigQuery",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
    tags=["yelp", "json", "csv", "gcs", "bigquery"],
) as dag:

    convert_and_upload_clean_csv = PythonOperator(
        task_id="convert_and_upload_clean_csv",
        python_callable=convert_json_to_cleaned_csv
    )

    load_cleaned_csv_to_bq = GCSToBigQueryOperator(
        task_id="load_cleaned_csv_to_bq",
        bucket=BUCKET_NAME,
        source_objects=[CLEAN_CSV_BLOB],
        destination_project_dataset_table=f"{GCP_PROJECT}.{BQ_DATASET}.{BQ_TABLE}",
        source_format='CSV',
        skip_leading_rows=1,
        write_disposition='WRITE_TRUNCATE',
        autodetect=True,
        max_bad_records=50,
        ignore_unknown_values=True,
    )

    convert_and_upload_clean_csv >> load_cleaned_csv_to_bq
