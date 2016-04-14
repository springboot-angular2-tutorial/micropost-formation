#!/bin/sh

# Take over current value, if not new value was specified.

TF_VAR_ami_web=${TF_VAR_ami_web:=$(terraform output ami_web)}
if [ -n "${TF_VAR_ami_web}" ]; then
  export TF_VAR_ami_web
fi

TF_VAR_web_desired_capacity=$(terraform output web_desired_capacity)
if [ -n "${TF_VAR_web_desired_capacity}" ]; then
  export TF_VAR_web_desired_capacity
fi
