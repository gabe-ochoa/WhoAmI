ENV['RACK_ENV'] = 'test'

require ::File.expand_path('../../config/environment',  __FILE__)
require 'rspec'
require 'webmock/rspec'
require 'pry'
require 'rack/test'
require './config/environment'

RSpec.configure do |config|
  include Rack::Test::Methods
  def app() Sinatra::Application end

  config.mock_with :mocha
  config.color = true
  config.only_failures
end

def load_fixture(filename)
  File.read File.expand_path("../fixtures/#{filename}", __FILE__)
end

def json_fixture(filename)
  JSON.parse(load_fixture(filename))
end
