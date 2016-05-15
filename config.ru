# Add current directory to load path
$:.unshift('.')


# Run the Sinatra app
require 'app'
run App
