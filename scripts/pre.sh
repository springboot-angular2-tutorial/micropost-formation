#!/usr/bin/env bash

# Set ASG desired capacity, if it exists
asg_name=$(terraform output web_asg_name)
if [ -n "${asg_name}" ]; then
  desired_capacity=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name ${asg_name} | jq '.AutoScalingGroups[0].DesiredCapacity')
  # Respect current desired capacity
  export TF_VAR_web_desired_capacity="${desired_capacity}"
fi
