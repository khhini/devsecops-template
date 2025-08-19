locals {
  branch_name = var.app_env == "prd" ? "main" : var.app_env
}




#######################################
# Use Shared Registry
#######################################
locals {
  registry_id       = data.google_artifact_registry_repository.app_registry.repository_id
  registry_location = data.google_artifact_registry_repository.app_registry.location
  registry_project  = data.google_artifact_registry_repository.app_registry.project
  app_image_uri     = "${local.registry_location}-docker.pkg.dev/${local.registry_project}/${local.registry_id}/${var.app_name}/${var.app_service}"
}

data "google_artifact_registry_repository" "app_registry" {
  location      = var.location
  project       = var.project_id
  repository_id = var.artifact_registry_id
}

#######################################
# Use new Registry per Env
#######################################
# locals {
#   registry_id       = google_artifact_registry_repository.app_registry.repository_id
#   registry_location = google_artifact_registry_repository.app_registry.location
#   registry_project  = google_artifact_registry_repository.app_registry.project
#   app_image_uri     = "${local.registry_location}-docker.pkg.dev/${local.registry_project}/${local.registry_id}/${var.app_name}/${var.app_service}"
# }
#
# resource "google_artifact_registry_repository" "app_registry" {
#   project       = var.project_id
#   location      = var.location
#   repository_id = coalesce(var.artifact_registry_id, var.app_name)
#   format        = "DOCKER"
#
# }
#
# resource "google_artifact_registry_repository_iam_member" "artifact_registry_writer" {
#   repository = google_artifact_registry_repository.app_registry.id
#   role       = "roles/artifactregistry.writer"
#   member     = "serviceAccount:${var.cicd_service_account}"
# }

#######################################
# Github Repository
#######################################
resource "google_cloudbuildv2_repository" "sample_app" {
  location          = var.location
  project           = var.project_id
  name              = "${var.app_name}-${var.app_service}"
  parent_connection = var.cloudbuildv2_github_conn
  remote_uri        = var.github_remote_uri
}

resource "google_cloudbuild_trigger" "continuous_integration" {
  name            = "${var.app_name}-${var.app_service}-ci-${var.app_env}"
  location        = var.location
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/${var.cicd_service_account}"

  repository_event_config {
    repository = google_cloudbuildv2_repository.sample_app.id
    push {
      branch = "^${local.branch_name}.*"
    }
  }

  ignored_files = [
    "${var.deployment_config_path}/build/cloudbuild.cd.yaml",
    "${var.deployment_config_path}/scripts/*",
    "**/*.tf"
  ]

  filename = "${var.deployment_config_path}/build/cloudbuild.yaml"

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}


resource "google_cloudbuild_trigger" "continuous_deployment" {
  name            = "${var.app_name}-${var.app_service}-cd-${var.app_env}"
  location        = var.location
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/${var.cicd_service_account}"


  git_file_source {
    path       = "${var.deployment_config_path}/build/cloudbuild.cd.yaml"
    repository = google_cloudbuildv2_repository.sample_app.id
    revision   = "refs/heads/${local.branch_name}"
    repo_type  = "GITHUB"
  }

  source_to_build {
    repository = google_cloudbuildv2_repository.sample_app.id
    ref        = "refs/heads/${local.branch_name}"
    repo_type  = "GITHUB"
  }

}


