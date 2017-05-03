#!/opt/puppetlabs/puppet/bin/ruby
require 'optparse'
require 'puppet'
require 'yaml'
require 'net/http'
require 'uri'
require 'json'

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-j [/path/to/data.json]', '--json_file [/path/to/data.json]', "Path to data.json file") do |j|
    options[:json_file] = j
  end
  opts.on('-a [code_manager|classifier|rbac]', '--api [code_manager|classifier|rbac]', "API to contact") do |a|
    options[:api] = a
  end
  opts.on('-e [ARG]', '--endpoint [ARG]', "API end point") do |e|
    options[:endpoint] = e
  end
  opts.on('-m [post|get]', '--method [post|get]', "HTTP Method") do |m|
    options[:method] = m
  end
  opts.on('-h', '--help', 'Display this help') do 
    puts opts
    exit
  end
end

parser.parse!

if options[:api]
  fail "API can only be code_manager, classifier or rbac" unless ['code_manager','classifier','rbac'].include? options[:api]
end

if options[:json_file]
  fail "#{options[:json_file]} does not exist" unless File.file?(options[:json_file])
  $data = YAML.load_file(options[:json_file])
end

# This doesn't do anything
if options[:method]
  fail "Allowed methods post and get" unless ['post','get'].include? options[:method]
end

Puppet.initialize_settings

certname = Puppet.settings[:certname]
hostcert = File.read(Puppet.settings[:hostcert])
hostprivkey = File.read(Puppet.settings[:hostprivkey])
localcert = Puppet.settings[:localcacert]
rbac_url = "https://#{certname}:4433/rbac-api/v1"
classifier_url = "https://#{certname}:4433/classifier-api/v1"
cm_url = "https://#{certname}:8170/code-manager/v1"

# endpoints: rbac/users, rbac/auth/token, classifier/groups, cm/deploys, classifier/update-classes

case options[:api]
when 'rbac' 
  $url = rbac_url
when 'classifier'
  $url = classifier_url
when 'code_manager'
  $url = cm_url
end

uri = URI("#{$url}/#{options[:endpoint]}")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.cert = OpenSSL::X509::Certificate.new(hostcert)
http.key = OpenSSL::PKey::RSA.new(hostprivkey)
http.ca_file = localcert
http.verify_mode = OpenSSL::SSL::VERIFY_CLIENT_ONCE

request = Net::HTTP::Post.new(uri.request_uri)
request.body = $data.to_json
request.content_type = 'application/json'

response = http.request(request)
output = "Response #{response.code}"
if response.body != "" then
  output << ": "
  output << response.body
end

puts output
