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
    hostname = etcd_set(mac_address, generate_hostname(service))
  end
  hostname
end

def etcd_set(mac_address, value)
  response = HTTParty.put("#{etcd_uri}/#{mac_address}", :query => {value: value})
  parse_etcd_response(response)
end

def etcd_get(mac_address)
  response = HTTParty.get("#{etcd_uri}/#{mac_address}")
  parse_etcd_response(response)
end

def etcd_get_keyspace
  response = HTTParty.get(etcd_uri)
end

def parse_etcd_response(response)
  begin
    JSON.parse(response)['node']['value']
  rescue NoMethodError
    ''
  end
end

def generate_hostname(service)
  case service
  when 'kubernetes'
    "k8s-rpi-worker-#{next_index}"
  when 'wink-tv'
    "wink-tv-#{next_index}"
  end
end

def next_index
  last_hostname = JSON.parse(etcd_get_keyspace)['node']['nodes'].last['value']
  last_hostname.split('-').last.to_i + 1
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

def etcd_client
  client ||= Etcd::Client.connect(uris: 'http://localhost:2379')
end
