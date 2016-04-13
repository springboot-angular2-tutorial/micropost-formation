#!/bin/sh

. $(dirname $0)/terraform-enable-remote.sh

terraform $@ \
  -state="${ENV}.tfstate" \
  -refresh=true \
  -var "env=${ENV}"

terraform remote push
