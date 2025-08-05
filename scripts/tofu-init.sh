#/bin/bash
tofu init -var-file="environments/prd/terraform.tfvars" -backend-config="bucket=khhini-devops-2705-bkt" -backend-config="prefix=tofu/sample-app/prd"
