# Add current directory to load path
$:.unshift('.')

# Setup dotenv
require 'dotenv'
Dotenv.load

# Run the Sinatra app
require 'app'
run App
