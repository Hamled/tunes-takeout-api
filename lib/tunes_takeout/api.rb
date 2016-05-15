require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/json'

module TunesTakeout
  class API < Sinatra::Base
    register Sinatra::Namespace

    namespace '/v1' do
      get '/ping' do
        json data: 'pong'
      end
    end
  end
end
