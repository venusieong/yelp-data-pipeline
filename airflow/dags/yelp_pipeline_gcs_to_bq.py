from airflow import DAG
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

# Config
BUCKET_NAME = "yelp_gcp_bucket"
GCP_PROJECT = "yelpdatapipeline"
DATASET_NAME = "yelp_dataset"

# File to Table mapping (excluding 'business')
file_to_table = {
    "yelp_academic_dataset_checkin.json": "checkin",
    "yelp_academic_dataset_review.json": "review",
    "yelp_academic_dataset_tip.json": "tip",
    "yelp_academic_dataset_user.json": "user",
}

# Default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'email_on_failure': False,
    'email_on_retry': False,
}

# Instantiate the DAG
with DAG(
    dag_id='yelp_gcs_to_bigquery',
    default_args=default_args,
    description='Load Yelp data (except business) from GCS to BigQuery',
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
    tags=["yelp", "gcs", "bigquery"],
) as dag:

    for file_name, table_name in file_to_table.items():
        GCSToBigQueryOperator(
            task_id=f'load_{table_name}_to_bq',
            bucket=BUCKET_NAME,
            source_objects=[file_name],
            destination_project_dataset_table=f'{GCP_PROJECT}.{DATASET_NAME}.{table_name}',
            source_format='NEWLINE_DELIMITED_JSON',
            autodetect=True,
            write_disposition='WRITE_TRUNCATE',
            max_bad_records=20,
            ignore_unknown_values=True,
        )