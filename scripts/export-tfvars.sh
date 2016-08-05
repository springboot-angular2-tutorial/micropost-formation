#!/bin/sh

# Take over current value, if not new value was specified.
TF_VAR_web_desired_capacity=$(terraform output web_desired_capacity)
if [ -n "${TF_VAR_web_desired_capacity}" ]; then
  export TF_VAR_web_desired_capacity
fi

if [ "${ENV}" = "prod" ]; then
  # prod is special
  export TF_VAR_web_host_name="micropost"
else
  export TF_VAR_web_host_name="micropost-${ENV}"
fi
