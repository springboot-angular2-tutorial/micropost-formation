#!/bin/sh

export ENV=$(echo "${TRAVIS_BRANCH}" | perl -ne "print $& if /(?<=deploy\/).*/")
if [ -z "${ENV}" ]; then
  echo "Branch name does not match with deploy/xxx. Exit now."
  exit 0
fi

echo "Enable Terraform remote."
scripts/terraform-enable-remote.sh

echo "Save current output to use it later"
terraform output | tee out_before

echo "Set ami_web."
TF_VAR_ami_web=${TF_VAR_ami_web:=$(terraform output ami_web)}
if [ -z "${TF_VAR_ami_web}" ]; then
  echo "ami_web is empty. Exit now."
  exit 0
fi
export TF_VAR_ami_web
echo "ami_web is ${TF_VAR_ami_web} ."

scripts/terraform-wrapper.sh plan
if [ $? -ne 0 ]; then
  echo "Plan failed."
  exit 1
fi

scripts/terraform-wrapper.sh apply
if [ $? -ne 0 ]; then
  echo "Apply failed."
  exit 1
fi

# Deploy app when initial deployment
if [ ! -s out_before ]; then scripts/build-app.sh ; fi
