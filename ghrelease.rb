require 'net/http'
require 'json'

OWNER     = ENV["OWNER"]
GH_TOKEN  = ENV["OTOKEN"]

repo = ''
rel_name = ''

args = ARGV.each
files = []

loop do
  arg = args.next
  case arg
  when "--artifact"
    arg = args.next
    repo = arg
  when "--version"
    arg = args.next
    rel_name = arg
  else
    files << arg
  end

  if arg == ARGV.last
    break
  end
end

baseurl   = "https://api.github.com/"
DATA_TYPE = "application/octet-stream"

def sendRequest(method, url, body)
  uri = URI(url)
  body_json = body.to_json
  method_class = method == 'get' ? Net::HTTP::Get : Net::HTTP::Post
  req = method_class.new(uri)
  req.basic_auth OWNER, GH_TOKEN
  req.content_type = DATA_TYPE
  req.body = body_json

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) { | http |
    http.request(req)
  }

  JSON.parse(res.body)
end

get_url = "#{baseurl}repos/#{OWNER}/#{repo}/releases/tags/#{rel_name}"
res = sendRequest('get', get_url, {})

unless res.has_key? "upload_url"
  create_url = "#{baseurl}repos/#{OWNER}/#{repo}/releases"
  res = sendRequest('post', create_url, { :tag_name => rel_name })
end

unless res.has_key? "upload_url"
  raise "Could not find or create release"
end

files.each { | file_name |
  upload_url = res['upload_url'].sub '{?name}', '?name=' + file_name
  file_data = File.read(file_name)
  upload_res = sendRequest('post', upload_url, file_data);
  if upload_res.has_key? 'url'
    puts "Uploaded #{file_name}"
  else
    puts "Error uploading #{file_name}: #{upload_res['errors'][0]['code']}"
  end
}
