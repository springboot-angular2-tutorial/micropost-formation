#!/bin/sh

. $(dirname $0)/terraform-enable-remote.sh

terraform $@ \
  -state="${ENV}.tfstate" \
  -refresh=true \
  -var "env=${ENV}"
status=$?

# Need to push state, even if apply was failed.
terraform remote push

exit status
