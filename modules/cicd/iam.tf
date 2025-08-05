#trivy:ignore:AVD-GCP-0007
resource "google_project_iam_member" "cicd_agent" {
  for_each = toset([
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.securityAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/artifactregistry.admin",
    "roles/secretmanager.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/run.admin"
  ])
  member  = "serviceAccount:${var.cicd_service_account}"
  project = var.project_id
  role    = each.value
}

