#!/bin/sh

if [ "${ENV}" = "prod" ]; then
  # prod is special
  export TF_VAR_web_host_name="micropost"
else
  export TF_VAR_web_host_name="micropost-${ENV}"
fi
