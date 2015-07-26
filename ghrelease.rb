require 'net/http'
require 'json'

owner     = ENV["OWNER"]
gh_token  = ENV["OTOKEN"]

repo      = ARGV[0].to_s
rel_name  = ARGV[1].to_s

baseurl   = "https://api.github.com/"
data_type = "application/octet-stream"

create_uri = URI("#{baseurl}repos/#{owner}/#{repo}/releases")

body_hash = { :tag_name => rel_name }
body_json = JSON.generate(body_hash)

req = Net::HTTP::Post.new(create_uri)
req.basic_auth owner, gh_token
req.content_type = data_type
req.body = body_json

params = { :tag_name => rel_name }

res = Net::HTTP.start(create_uri.hostname, create_uri.port, :use_ssl => true) { |http|
  http.request(req)
}

puts res.body
