require 'sinatra/base'
require 'lib/tunes_takeout'

class App < Sinatra::Application
  use TunesTakeout::API
end
