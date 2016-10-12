require 'aws-sdk'
require 'optparse'

option = ARGV.getopts(nil, 'domain:', 'region:')
           .inject({}) { |hash, (k, v)| hash[k.to_sym] = v; hash }

acm = Aws::ACM::Client.new(region: option[:region])
puts acm.list_certificates
       .certificate_summary_list
       .select { |c| c.domain_name == option[:domain] }
       .map(&:certificate_arn)
       .first
