#!/bin/sh

. $(dirname $0)/terraform-enable-remote.sh
. $(dirname $0)/export-tfvars.sh

terraform get

terraform $@ \
  -state="${ENV}.tfstate" \
  -refresh=true \
  -var "env=${ENV}"
status=$?

# Need to push state, even if apply was failed.
terraform remote push

exit ${status}
