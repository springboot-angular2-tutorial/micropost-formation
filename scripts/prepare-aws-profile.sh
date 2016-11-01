#!/usr/bin/env bash

set -u

mkdir ${HOME}/.aws

cat << EOS > ${HOME}/.aws/credentials
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOS

cat << EOS > ${HOME}/.aws/config
[default]
region = ${AWS_DEFAULT_REGION}
output = json

[profile micropost-stg]
role_arn = ${STG_ROLE_ARN}
source_profile = default
region = ${AWS_DEFAULT_REGION}
output = json

[profile micropost-prod]
role_arn = ${PROD_ROLE_ARN}
source_profile = default
region = ${AWS_DEFAULT_REGION}
output = json

EOS

chmod 600 ${HOME}/.aws/credentials
chmod 600 ${HOME}/.aws/config

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION
unset STG_ROLE_ARN
unset PROD_ROLE_ARN
