from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
import requests
from google.cloud import storage
import zipfile
import io

# Function to download Yelp data and upload to GCS
def download_and_upload_to_gcs():
    # Define the URL of the Yelp dataset
    url = "https://business.yelp.com/external-assets/files/Yelp-JSON.zip"
    
    # Fetch the data from Yelp
    response = requests.get(url)
    if response.status_code == 200:
        # Unzip the content
        with zipfile.ZipFile(io.BytesIO(response.content)) as zip_ref:
            zip_ref.extractall("/tmp/yelp_data")
        
        # Google Cloud Storage configuration
        bucket_name = 'yelp_gcp_bucket'
        client = storage.Client()
        bucket = client.get_bucket(bucket_name)

        # Upload files to GCS
        for filename in os.listdir("/tmp/yelp_data"):
            local_path = f"/tmp/yelp_data/{filename}"
            if os.path.isfile(local_path):
                blob = bucket.blob(f"yelp_data/{filename}")
                blob.upload_from_filename(local_path)

        print("Yelp data uploaded successfully!")
    else:
        print(f"Failed to download Yelp data, status code: {response.status_code}")

# Define the default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 4, 7),  # Set the start date to today
}

# Create the DAG
with DAG(
    'yelp_to_gcs',
    default_args=default_args,
    description='Download Yelp data and upload to GCS',
    # Commented out the schedule_interval line to prevent automatic scheduling
    # schedule_interval='@daily',  # This will schedule the DAG to run daily
    catchup=False,
) as dag:

    # Define the task to run the function
    task = PythonOperator(
        task_id='download_and_upload_to_gcs',
        python_callable=download_and_upload_to_gcs,
    )
