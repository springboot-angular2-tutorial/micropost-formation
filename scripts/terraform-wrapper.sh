#!/bin/sh

. $(dirname $0)/terraform-enable-remote.sh

# Use ami which was used last time.
# This value can be overwritten by -var "ami_web=ami-12345"
export TF_VAR_ami_web=$(terraform output ami_web)
if [ -z "${TF_VAR_ami_web}" ]; then
  unset TF_VAR_ami_web # use default on variables.tf
fi

terraform $@ \
  -state="${ENV}.tfstate" \
  -refresh=true \
  -var "env=${ENV}"

terraform remote push
