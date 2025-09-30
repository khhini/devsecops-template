variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-southeast2"

}

variable "zone" {
  type    = string
  default = "asia-southeast2-a"
}

variable "app_name" {
  type = string

}

variable "app_service" {
  type = string

}

variable "app_env" {
  type = string
}

variable "devops_project_id" {
  type = string
}

variable "devops_location" {
  type = string
}

variable "devops_service_account" {
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

variable "app_image_tag" {
  type    = string
  default = null
}
