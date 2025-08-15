#/bin/bash
_APP_NAME=sample-app
_APP_SERVICE=backend
_TOFU_BACKEND_BUCKET=ebc-devops-bkt
_DEPLOYMENT_CONFIG_PATH=./deployments
LOCATION=asia-southeast2

_cloudbuild_cd_trigger=$(tofu output continuous_deployment_trigger | tr -d '"')
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
COMMIT_SHA=$(tofu output app_image_tag | tr -d '"')
_TOFU_BACKEND_PREFIX=tofu/${_APP_NAME}/${_APP_SERVICE}

gcloud builds triggers run ${_cloudbuild_cd_trigger} \
  --branch=${BRANCH_NAME} \
  --substitutions=_DEPLOYMENT_CONFIG_PATH=${_DEPLOYMENT_CONFIG_PATH},_TOFU_BACKEND_BUCKET=${_TOFU_BACKEND_BUCKET},_TOFU_BACKEND_PREFIX=${_TOFU_BACKEND_PREFIX},_APP_IMAGE_TAG=$COMMIT_SHA \
  --project=ebc-source-code \
  --region=${LOCATION}
