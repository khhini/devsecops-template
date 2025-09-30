#/bin/bash
_APP_NAME=sample-app
_APP_SERVICE=backend
_TOFU_BACKEND_BUCKET=khhini-devops-2705-bkt

_TOFU_BACKEND_PREFIX=tofu/${_APP_NAME}/${_APP_SERVICE}

_build_env=$(git rev-parse --abbrev-ref HEAD)
if [ "${_build_env}" = "main" ]; then
  _build_env=prd
fi
tofu init -var-file="environments/${_build_env}/terraform.tfvars" -backend-config="bucket=${_TOFU_BACKEND_BUCKET}" -backend-config="prefix=${_TOFU_BACKEND_PREFIX}/${_build_env}" -migrate-state
