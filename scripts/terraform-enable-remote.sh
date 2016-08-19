#!/bin/sh

if [ -z "${ENV}" ]; then
  echo "ENV is required."
  exit 1
fi

rm -rf ./.terraform/

terraform remote config \
  -state="${ENV}.tfstate" \
  -backend=S3 \
  -backend-config="region=ap-northeast-1" \
  -backend-config="bucket=tfstate.hana053.com" \
  -backend-config="key=${ENV}.tfstate"
terraform remote pull
