#!/usr/bin/env bash

if [ "${ENVIRONMENT}" = "prod" ]; then
  # reset current role if exists
  test ! -v AWS_SESSION_TOKEN && direnv reload > /dev/null 2>&1
  # switch to production role
  source scripts/switch-production-role.sh
fi

export TF_VAR_aws_region=${AWS_DEFAULT_REGION}
export TF_VAR_alb_certificate_arn=$(node scripts/get_certificate_arn.js -d "*.hana053.com")

asg_name=$(terraform output web_asg_name)
if [ -n "${asg_name}" ]; then
  desired_capacity=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${asg_name} | jq '.AutoScalingGroups[0].DesiredCapacity')
  # respect current desired capacity
  export TF_VAR_web_desired_capacity="${desired_capacity}"
fi

# zip lambda functions

dirs=$(find functions -depth 1 -type d )
for dir in ${dirs}
do
  (
    cd ${dir}
    zip -X -r ../$(echo ${dir} | cut -d"/" -f2).zip *
  )
done
