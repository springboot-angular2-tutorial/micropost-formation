#!/bin/sh

TF_VAR_ami_web=${TF_VAR_ami_web:=$(terraform output ami_web)}
if [ -n "${TF_VAR_ami_web}" ]; then
  export TF_VAR_ami_web
else
  echo "ami_web is required. Exit now."
  exit 1
fi

TF_VAR_web_desired_capacity=$(terraform output web_desired_capacity)
if [ -n "${TF_VAR_web_desired_capacity}" ]; then
  export TF_VAR_web_desired_capacity
fi
