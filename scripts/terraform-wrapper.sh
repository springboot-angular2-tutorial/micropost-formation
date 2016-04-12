#!/bin/sh

. $(dirname $0)/terraform-enable-remote.sh

# If TF_VAR_ami_web is defined already, use it.
# If TF_VAR_ami_web is not defined, get it from tfstate.
TF_VAR_ami_web=${TF_VAR_ami_web:=$(terraform output ami_web)}
if [ -n "${TF_VAR_ami_web}" ]; then
  export TF_VAR_ami_web
else
  exit
fi

terraform $@ \
  -state="${ENV}.tfstate" \
  -refresh=true \
  -var "env=${ENV}"

terraform remote push
