provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
