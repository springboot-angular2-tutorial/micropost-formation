#!/usr/bin/env bash

set -u

sudo cat << EOS > ${HOME}/.aws/credentials
[micropost-stg]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}

[micropost-prod]
role_arn = ${PROD_ROLE_ARN}
source_profile = micropost-stg
EOS

sudo cat << EOS > ${HOME}/.aws/config
[profile micropost-stg]
region = ${AWS_DEFAULT_REGION}
output = json

[profile micropost-prod]
region = ${AWS_DEFAULT_REGION}
output = json
EOS

sudo chmod 600 ${HOME}/.aws/credentials
sudo chmod 600 ${HOME}/.aws/config

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION
unset PROD_ROLE_ARN
