#/bin/bash
_app_image_tag=$(tofu output app_image_tag | tr -d '"')
_build_env=$(git rev-parse --abbrev-ref HEAD)
if [ "${_build_env}" = "main" ]; then
  _build_env=prd
fi
tofu plan -var-file="environments/${_build_env}/terraform.tfvars" -out="./tmp/environment-${_build_env}.plan" -var=app_image_tag=${_app_image_tag}
