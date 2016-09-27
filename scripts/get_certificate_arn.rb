require 'aws-sdk'

unless ARGV[0]
  puts 'Specify domain name.'
  exit 1
end
DOMAIN_NAME = ARGV[0]

acm = Aws::ACM::Client.new
puts acm.list_certificates
       .certificate_summary_list
       .select { |c| c.domain_name == DOMAIN_NAME }
       .map(&:certificate_arn)
       .first
