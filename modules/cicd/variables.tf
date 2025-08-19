variable "app_env" {
  type = string
}

variable "app_name" {
  type = string

}

variable "app_service" {
  type = string

}

variable "project_id" {
  type = string
}

variable "location" {
  type = string

}

variable "cicd_service_account" {
  type = string

}

variable "cloudbuildv2_github_conn" {
  type = string

}

variable "github_remote_uri" {
  type = string
}

variable "artifact_registry_id" {
  type    = string
  default = null

}

variable "deployment_config_path" {
  type    = string
  default = "."

}
