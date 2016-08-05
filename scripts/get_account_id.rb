require 'aws-sdk'

sts = Aws::STS::Client.new(region: 'ap-northeast-1')
puts sts.get_caller_identity.account