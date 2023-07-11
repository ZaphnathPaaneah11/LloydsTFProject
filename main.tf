#required terraform version

terraform {
    required_version = ">=0.13"
}

 
#provider block
provider "google" {
 credentials = "${file("project-filename.json")}"  
 project = "sichuwayproject"
 region = "europe-west2"
 zone =" "europe-west2a"
  }

#private GCP storage bucket with a retention policy
resource "google_storage_bucket" "private" {
 name = "numatf-bucket"
 public_access_prevention = "enforced"  #privatize
 location = "EU" 
 storage_class = "STANDARD"
 uniform_bucket_level_access = true   #object access determined by bucket permissions.
  
 retention_policy {
  retention_period = 30 # can delete after 30 seconds
  }
}



# BigQuery dataset with sample data which optimises query performance
resource "google_bigquery_dataset" "tf_ds" { 
 dataset_id = "tfds1"
 }

resource "google_bigquery_table" "tf_tb" {
	table_id = "tftb1"	
	dataset_id = google_bigquery_dataset.tf_ds.dataset_id
	deletion_protection = "false" # allows deletion

clustering {
	
	}
}





# A user managed vertex AI Notebook

resource "google_project_service" "notebooks" {
	provider           = google
	service            = "notebooks.googleapis.com"
	disable_on_destroy = false
}


resource "google_notebooks_instance" "basic_instance" {
	project      = "sichuwayproject"
	name         = "tfnotebook"
	provider     = google
	location     = "europe-west2-a"
	machine_type = "g1-small" # cheapest for demonstration purposes
	

vm_image {
	project      = "deeplearning-platform-release"  # public project by google for deep learning special machine images
	image_family = "tf-ent-2-9-cu113-notebooks"
  }
	
depends_on = [
	 google_project_service.notebooks
 ]
}
