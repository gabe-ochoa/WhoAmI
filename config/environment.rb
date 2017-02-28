# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'rubygems'

# Require gems we care about
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

if ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load
end

require 'sinatra/base'
require 'logger'
require 'json'

module WhoAmI
  def self.logger
    if ENV['SYSLOG_LOGGING'] == 'true'
      @logger ||= create_syslog_logger
    else
      @logger ||= create_stdout_logger
    end
  end

  def self.create_syslog_logger
    uri = URI(ENV.fetch('LOGGING_URL', 'udp://127.0.0.1:514'))
    program = ENV.fetch('LOGGING_PROGRAM_NAME', 'arlo-service')
    logger = RemoteSyslogLogger.new(uri.host, uri.port, program: program)
    logger.level = Logger.const_get(ENV['LOG_LEVEL'] || 'INFO')
    logger
  end

  def self.create_file_logger
    file = File.new(File.expand_path("../log/#{ENV['RACK_ENV']}.log", File.dirname(__FILE__)), 'a+')
    file.sync = true
    logger = Logger.new(file)
    logger.level = Logger.const_get(ENV['LOG_LEVEL'] || 'INFO')
    logger
  end

  def self.create_stdout_logger
    logger = Logger.new(STDOUT)
    logger.level = Logger.const_get(ENV['LOG_LEVEL'] || 'INFO')
    logger
  end

  class Base < Sinatra::Base
    configure do
      use Rack::CommonLogger, WhoAmI.logger
    end

    configure :production, :staging, :development do
      enable :logging
    end
  end
end

require './app'
