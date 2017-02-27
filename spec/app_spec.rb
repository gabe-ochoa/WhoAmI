require 'spec_helper'
require_relative '../app'

RSpec.describe WhoAmI, type: :controllers do
  include Rack::Test::Methods

  it "GET / returns a 200 and an existential question" do
    get('/')
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('Who am I? I donno, who are you?')
  end

  it 'GET /health returns a 204' do
    get('/health')
    expect(last_response.status).to eq(204)
  end

  it 'GET /hostname?mac=10:20:30:40:50:60 returns a 200 and a hostname' do
    stub_request(:get, "http://127.0.0.1:2739/v2/keys/WhoAmI/kubernetes/10:20:30:40:50:60").
      to_return(:status => 200, :body => load_fixture('etcd_get.json'))

    get('hostname?mac=10:20:30:40:50:60')
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('k8s-rpi-worker-1')
  end

  it 'GET /hostname?mac=12:20:30:40:50:60 and return a hostname with the next index' do
    stub_request(:get, "http://127.0.0.1:2739/v2/keys/WhoAmI/kubernetes/12:20:30:40:50:60").
      to_return(:status => 200, :body => load_fixture('etcd_key_not_found.json'))

    stub_request(:get, "http://127.0.0.1:2739/v2/keys/WhoAmI/kubernetes").
      to_return(:status => 200, :body => load_fixture('etcd_get_keys.json'))

    stub_request(:put, "http://127.0.0.1:2739/v2/keys/WhoAmI/kubernetes/12:20:30:40:50:60?value=k8s-rpi-worker-3").
      to_return(:status => 200, :body => load_fixture('etcd_key_set.json'))

    get('hostname?mac=12:20:30:40:50:60')
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('k8s-rpi-worker-3')
  end
end
