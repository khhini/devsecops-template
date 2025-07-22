output "app_image_uri" {
  value = local.app_image_uri
}

output "continuous_deployment_trigger" {
  value = google_cloudbuild_trigger.continuous_deployment.trigger_id
}

output "continuous_integration_trigger" {
  value = google_cloudbuild_trigger.continuous_integration.trigger_id
}

output "app_env" {
  value = var.app_env
}

output "app_image_tag" {
  value = var.app_image_tag
}

output "cloud_run_svc_service_account" {
  value = google_service_account.cloud_run_svc.email
}

output "cloud_run_svc_uri" {
  value = google_cloud_run_v2_service.service.uri
}

