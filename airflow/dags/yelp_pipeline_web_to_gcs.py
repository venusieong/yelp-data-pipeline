from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import requests
import zipfile
import tarfile
import os
from google.cloud import storage
import shutil

# Constants
DATA_URL = "https://business.yelp.com/external-assets/files/Yelp-JSON.zip"
ZIP_FILE = "/tmp/yelp_data.zip"
EXTRACT_DIR = "/tmp/yelp_data"
BUCKET_NAME = "yelp_gcp_bucket"  
SERVICE_ACCOUNT_KEY = "/opt/airflow/terraform/terraform-service-account.json"

# Define download, extract and upload function
def download_extract_upload_cleanup():
    print("\U0001F4E5 Downloading ZIP file...")
    response = requests.get(DATA_URL, stream=True, headers={"User-Agent": "Mozilla/5.0"})
    with open(ZIP_FILE, "wb") as f:
        shutil.copyfileobj(response.raw, f)

    print("\U0001F4E6 Extracting ZIP file...")
    if not zipfile.is_zipfile(ZIP_FILE):
        raise Exception("Downloaded file is not a valid ZIP archive.")

    with zipfile.ZipFile(ZIP_FILE, "r") as zip_ref:
        zip_ref.extractall(EXTRACT_DIR)

    # Step 2: Locate and extract the .tar file
    extracted_zip_dir = os.path.join(EXTRACT_DIR, 'Yelp JSON')  # where the TAR is expected
    tar_files = [f for f in os.listdir(extracted_zip_dir) if f.endswith('.tar')]

    if not tar_files:
        raise Exception("No .tar file found inside extracted ZIP directory.")

    tar_path = os.path.join(extracted_zip_dir, tar_files[0])

    print("\U0001F4C2 Extracting TAR file inside ZIP...")
    with tarfile.open(tar_path, 'r') as tar:
        tar.extractall(EXTRACT_DIR)

    print("☁️ Uploading extracted files to GCP bucket...")
    storage_client = storage.Client.from_service_account_json(SERVICE_ACCOUNT_KEY)
    bucket = storage_client.bucket(BUCKET_NAME)

    for root, _, files in os.walk(EXTRACT_DIR):
        for file in files:
            local_path = os.path.join(root, file)
            blob_path = os.path.relpath(local_path, EXTRACT_DIR)
            blob = bucket.blob(blob_path)
            blob.upload_from_filename(local_path)
            print(f"✅ Uploaded {blob_path}")

    print("🧹 Cleaning up temporary files...")
    try:
        shutil.rmtree(EXTRACT_DIR)
        os.remove(ZIP_FILE)
    except Exception as e:
        print(f"Warning during cleanup: {e}")

    print("✅ Done.")

# Define DAG
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 4, 10),
    'retries': 1,
}

dag = DAG(
    'yelp_pipeline_full_automation',
    default_args=default_args,
    description='Fully automated Yelp pipeline with download, extract, upload, and cleanup',
    schedule_interval=None,
    catchup=False
)

task = PythonOperator(
    task_id='download_extract_upload_cleanup',
    python_callable=download_extract_upload_cleanup,
    dag=dag
)
