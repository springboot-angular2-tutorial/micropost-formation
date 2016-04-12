#!/bin/sh

export ENV=$(echo "${TRAVIS_BRANCH}" | perl -ne "print $& if /(?<=deploy\/).*/")
if [ -z "${ENV}" ]; then
  echo "Branch name does not match with deploy/xxx. Exit now."
  exit
fi

# Enable Terraform Remote
scripts/terraform-enable-remote.sh

# Save current output to use it later
terraform output | tee out_before

# Execute Terraform and create tfstate on remote
scripts/terraform-wrapper.sh plan || exit
scripts/terraform-wrapper.sh apply

# Deploy app when initial deployment
if [ ! -s out_before ]; then scripts/build-app.sh ; fi
