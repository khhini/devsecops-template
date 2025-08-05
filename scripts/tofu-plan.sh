#/bin/bash
tofu plan -var-file="environments/prd/terraform.tfvars" -out="./tmp/environment-prd.plan" -var=app_image_tag=hello
