locals {
  enabled_services = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "run.googleapis.com"
  ]
}

resource "google_project_service" "enabled_service" {
  for_each = toset(local.enabled_services)
  service  = each.value
  project  = var.project_id
}
