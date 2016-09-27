require 'aws-sdk'
require 'awesome_print'

unless ARGV[0]
  puts 'Specify auto scaling group name.'
  exit 1
end
ASG_NAME = ARGV[0]

as = Aws::AutoScaling::Client.new
asg = Aws::AutoScaling::AutoScalingGroup.new(ASG_NAME, client: as)

if asg.desired_capacity * 2 > asg.max_size
  puts "Can not scale out to replace instances in #{ASG_NAME}."
  puts 'Consider increasing the max size of it.'
  exit 1
end

asg.set_desired_capacity(
  desired_capacity: asg.desired_capacity * 2,
  honor_cooldown: true,
)

# scaling policy will decrease desired capacity soon.
