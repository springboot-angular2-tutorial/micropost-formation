#!/bin/sh

. $(dirname $0)/terraform-enable-remote.sh

# If TF_VAR_ami_web is defined already, use it.
# If TF_VAR_ami_web is not defined, get it from tfstate.
TF_VAR_ami_web=${TF_VAR_ami_web:=$(terraform output ami_web)}
if [ -n "${TF_VAR_ami_web}" ]; then
  export TF_VAR_ami_web
else
  # use ubuntu default ami with 0 instances.
  export TF_VAR_max_size_web=0
  export TF_VAR_desired_capacity_web=0
fi

terraform $@ \
  -state="${ENV}.tfstate" \
  -refresh=true \
  -var "env=${ENV}"

terraform remote push
