#!/bin/sh

. $(dirname $0)/terraform-enable-remote.sh

# If TF_VAR_ami_web is defined already, use it.
# If TF_VAR_ami_web is not defined, get it from tfstate.
TF_VAR_ami_web=${TF_VAR_ami_web:=$(terraform output ami_web)}
if [ -z "${TF_VAR_ami_web}" ]; then
  echo "ami_web is empty"
  exit 1
fi
export TF_VAR_ami_web

terraform $@ \
  -state="${ENV}.tfstate" \
  -refresh=true \
  -var "env=${ENV}"

terraform remote push
