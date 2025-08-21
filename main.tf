locals {
  enabled_services = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "run.googleapis.com"
  ]
  labels = {
    app     = var.app_name
    env     = var.app_env
    service = var.app_service

  }

  app_image_uri = module.cicd.app_image_uri
}

module "cicd" {
  source                   = "./modules/cicd"
  project_id               = var.devops_project_id
  location                 = var.devops_location
  app_env                  = var.app_env
  app_name                 = var.app_name
  app_service              = var.app_service
  artifact_registry_id     = var.artifact_registry_id
  cloudbuildv2_github_conn = var.cloudbuildv2_github_conn
  github_remote_uri        = var.github_remote_uri
  cicd_service_account     = var.devops_service_account
  deployment_config_path   = "."

}

resource "google_project_service" "enabled_service" {
  for_each = toset(local.enabled_services)
  service  = each.value
  project  = var.project_id
}

resource "google_service_account" "cloud_run_svc" {
  account_id  = "${var.app_name}-${var.app_env}-sa"
  project     = var.project_id
  description = "Verifikasi Backend Service Account"
}

resource "google_service_account_iam_member" "cloud_run_svc_sa_user" {
  service_account_id = google_service_account.cloud_run_svc.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.devops_service_account}"
}

resource "google_cloud_run_v2_service" "service" {
  name                = "${var.app_name}-${var.app_service}-${var.app_env}-crs"
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run_svc.email
    containers {
      image = "${local.app_image_uri}:${var.app_image_tag}"
      env {
        name  = "NODE_ENV"
        value = var.app_env
      }

      # env {
      #   name = "DATABASE_PASSWORD"
      #   value_source {
      #     secret_key_ref {
      #       secret  = google_secret_manager_secret.database_password.secret_id
      #       version = "ebco_dev_dbuser"
      #     }
      #   }
      # }
    }

    labels = local.labels
  }
}

resource "google_cloud_run_v2_service_iam_member" "allow_unauthorized" {
  name   = google_cloud_run_v2_service.service.name
  role   = "roles/run.invoker"
  member = "allUsers"
}
