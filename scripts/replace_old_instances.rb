require 'aws-sdk'
require 'awesome_print'

unless ARGV[0]
  puts 'Specify auto scaling group name.'
  exit 1
end
ASG_NAME = ARGV[0]

as = Aws::AutoScaling::Client.new
asg = Aws::AutoScaling::AutoScalingGroup.new(ASG_NAME, client: as)
elb = Aws::ElasticLoadBalancing::Client.new

old_instances = asg.instances

if asg.desired_capacity * 2 > asg.max_size
  puts "Can not scale out to replace instances in #{ASG_NAME}."
  puts 'Consider increasing the max size of it.'
  exit 1
end

asg.set_desired_capacity(
  desired_capacity: asg.desired_capacity * 2,
  honor_cooldown: true,
)

# TODO use target group instead of elb
is_all_in_service = lambda do
  asg.reload
  in_services = asg.load_balancers
                  .map(&:load_balancer_name)
                  .map { |lb_name| elb.describe_instance_health(load_balancer_name: lb_name).instance_states }
                  .flatten
                  .select { |s| s.state == 'InService' }
  in_services.size >= asg.desired_capacity
end

puts 'Scaling out to replace old instances.'
until is_all_in_service.call
  print '.'
  sleep 5
end
puts ''
puts 'Completed to scale out.'

puts 'Terminating old instances.'
old_instances.each do |i|
  i.terminate(should_decrement_desired_capacity: true)
end
puts 'Done.'
