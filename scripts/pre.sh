#!/usr/bin/env bash

if [ "${ENVIRONMENT}" = "prod" ]; then
  # reset current role if exists
  test ! -v AWS_SESSION_TOKEN && direnv reload
  # switch to production role
  source scripts/switch-production-role.sh
fi

certificate_arn=$(aws acm list-certificates | jq --raw-output '.CertificateSummaryList[] | select(.DomainName == "*.hana053.com") | .CertificateArn')

export TF_VAR_aws_region=${AWS_DEFAULT_REGION}
export TF_VAR_alb_certificate_arn=${certificate_arn}

asg_name=$(terraform output web_asg_name)
if [ -n "${asg_name}" ]; then
  desired_capacity=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${asg_name} | jq '.AutoScalingGroups[0].DesiredCapacity')
  # respect current desired capacity
  export TF_VAR_web_desired_capacity="${desired_capacity}"
fi

# zip lambda functions

dirs=$(find functions -mindepth 1 -maxdepth 1 -type d)
for dir in ${dirs}
do
  (
    cd ${dir}
    yarn install
    zip -X -r -q ../$(echo ${dir} | cut -d"/" -f2).zip *
  )
done
