require 'aws-sdk'
require 'awesome_print'

def rotated_images
  ec2 = Aws::EC2::Client.new
  ec2.describe_images(filters: [
    {
      name: 'tag:Rotated',
      values: ['true'],
    },
  ]).images.map()
end

def used_image_ids
  as = Aws::AutoScaling::Client.new
  as.describe_launch_configurations
    .launch_configurations
    .map(&:image_id)
end

def unused_rotated_images
  rotated_images.reject { |i| used_image_ids.include?(i.image_id) }
end

images = unused_rotated_images

puts 'Deregistering amis.'
images.map(&:image_id)
  .map { |id| Aws::EC2::Image.new(id) }
  .tap { |img| ap img }
  .each { |img| img.deregister rescue nil }

puts 'Removing snapshots related with de-registered ami.'
images.map { |i| i.block_device_mappings.map(&:ebs) }
  .flatten
  .compact
  .map(&:snapshot_id)
  .map { |id| Aws::EC2::Snapshot.new(id) }
  .tap { |s| ap s }
  .each { |s| s.delete rescue nil }
