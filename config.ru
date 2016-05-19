# Add current directory to load path
$:.unshift('.')

# Setup dotenv
begin
  require 'dotenv'
  Dotenv.load
rescue LoadError
end

# Run the Sinatra app
require 'app'
run App
