# Load the Environment
require ::File.expand_path('../config/environment',  __FILE__)

# require 'app'

require './app'

run WhoAmI::App
