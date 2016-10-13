#!/bin/sh

export TF_VAR_alb_certificate_arn=$(bundle exec ruby scripts/get_certificate_arn.rb --domain "*.hana053.com" --region ${AWS_DEFAULT_REGION})

asg_name=$(terraform output web_asg_name)
if [ -n "${asg_name}" ]; then
  desired_capacity=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${asg_name} | jq '.AutoScalingGroups[0].DesiredCapacity')
  echo "Current desired capacity is ${desired_capacity}."
  # respect current desired capacity
  export TF_VAR_web_desired_capacity="${desired_capacity}"
fi

if [ "${ENV}" = "prod" ]; then
  # prod is special
  export TF_VAR_web_host_name="micropost"
else
  export TF_VAR_web_host_name="micropost-${ENV}"
fi
