#!/usr/bin/env bash

# Ensure AWS profile
export AWS_PROFILE="micropost-${ENVIRONMENT}"

# Set AWS region. It's required.
export TF_VAR_aws_region=$(aws configure get region)

# Set ALB certificate ARN
export TF_VAR_alb_certificate_arn=$(aws acm list-certificates | jq --raw-output '.CertificateSummaryList[] | select(.DomainName == "*.hana053.com") | .CertificateArn')

# Set ASG desired capacity, if it exists
asg_name=$(terraform output web_asg_name)
if [ -n "${asg_name}" ]; then
  desired_capacity=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${asg_name} | jq '.AutoScalingGroups[0].DesiredCapacity')
  # respect current desired capacity
  export TF_VAR_web_desired_capacity="${desired_capacity}"
fi
