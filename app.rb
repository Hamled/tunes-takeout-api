require 'sinatra/base'
require 'active_support' # for Hash#slice and Hash#except
require 'lib/tunes_takeout'

class App < Sinatra::Application
  use TunesTakeout::API
end
