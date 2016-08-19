require 'optparse'
require 'faraday_middleware'
require 'faraday_middleware/aws_signers_v4'
require 'json'

option = ARGV.getopts(nil, 'host:', 'repository:', 'region:', 'bucket:', 'role_arn:', 'base_path:')
           .inject({}) { |hash, (k, v)| hash[k.to_sym] = v; hash }

conn = Faraday.new(url: "https://#{option[:host]}") do |faraday|
  faraday.request :aws_signers_v4,
                  credentials: Aws::Credentials.new(
                    ENV['AWS_ACCESS_KEY_ID'],
                    ENV['AWS_SECRET_ACCESS_KEY'],
                    ENV['AWS_SESSION_TOKEN']
                  ),
                  service_name: 'es',
                  region: option[:region]
  faraday.response :json, :content_type => /\bjson\b/
  faraday.response :raise_error
  faraday.adapter Faraday.default_adapter
end

res = conn.post do |req|
  req.url "/_snapshot/#{option[:repository]}"
  req.headers['Content-Type'] = 'application/json'
  req.body = {
    type: 's3',
    settings: {
      bucket: option[:bucket],
      region: option[:region],
      role_arn: option[:role_arn],
      base_path: option[:base_path],
    }
  }.to_json
end

puts res.body
