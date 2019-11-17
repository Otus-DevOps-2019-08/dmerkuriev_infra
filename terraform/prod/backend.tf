terraform {
  backend "gcs" {
    bucket = "storage-bucket-terraform-test-dm"
    prefix = "terraform/prod"
  }
}
