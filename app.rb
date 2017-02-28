require 'sinatra'
require 'json'
require 'httparty'

get '/' do
  # Who am I? I donno, who are you?
  'Who am I? I donno, who are you?'
end

get '/health' do
  return [204, "I'm alive!"]
end

get '/hostname' do
  # Get the hostname for a paritcular MAC address
  return [200, hostname(params['mac'], params['service'] = 'kubernetes')]
end

def hostname(mac_address, service)
  @service = service
  hostname = etcd_get(mac_address)
  if hostname.empty?
    puts "Hostname was empty"
    hostname = etcd_set(mac_address, generate_hostname(service))
  end
  puts "Returning Hostname: #{hostname}"
  hostname
end

def etcd_set(mac_address, value)
  puts "Setting etcd key for #{mac_address} to #{value}"
  response = HTTParty.put("#{etcd_uri}/#{mac_address}", :query => {value: value}).body
  puts response
  parse_etcd_response(response)
end

def etcd_get(mac_address)
  puts "Getting etcd key for #{mac_address}"
  response = HTTParty.get("#{etcd_uri}/#{mac_address}").body
  puts response
  parse_etcd_response(response)
end

def etcd_get_keyspace
  puts "Checking etcd keyspace for #{@service}"
  response = HTTParty.get(etcd_uri).body
end

def parse_etcd_response(response)
  begin
    JSON.parse(response)['node']['value']
  rescue NoMethodError
    ''
  end
end

def generate_hostname(service)
  puts "Generating hostname for service #{service}"
  case service
  when 'kubernetes'
    "k8s-rpi-worker-#{next_index}"
  when 'wink-tv'
    "wink-tv-#{next_index}"
  end
end

def next_index
  puts "Finding next index"
  begin
    keyspace = etcd_get_keyspace
    puts keyspace
    last_hostname = JSON.parse(keyspace)['node']['nodes'].last['value']
    last_hostname.split('-').last.to_i + 1
  rescue NoMethodError
    1
  end
end

def etcd_uri
  "http://#{etcd_hostname}:#{etcd_port}/v2/keys/WhoAmI/#{@service}"
end

def etcd_hostname
  ENV['ETCD_HOST'] || '127.0.0.1'
end

def etcd_port
  ENV['ETCD_PORT'] || '2379'
end
