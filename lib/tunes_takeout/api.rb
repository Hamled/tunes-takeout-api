require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/json'
require 'mongoid'
require 'uri'

module TunesTakeout
  class API < Sinatra::Base
    register Sinatra::Namespace

    configure :development do
      require "better_errors"
      use BetterErrors::Middleware
      BetterErrors.application_root = __dir__
    end

    configure do
      Mongoid.load! "config/mongoid.yml"
    end

    DEFAULT_LIMIT = 10

    namespace '/v1' do
      get '/ping' do
        json data: 'pong'
      end

      get '/search' do
        query = params['query']
        limit = (params['limit'] || DEFAULT_LIMIT).to_i
        seed = params['seed'] || query

        suggestions = Suggestion.search(query, limit, seed)

        json({
          href: canonical_url({
            query: query,
            limit: limit,
            seed: seed
          }),
          suggestions: suggestions
        })
      end

      helpers do
        def canonical_url(params)
          url = URI(request.url)
          url.query = URI.encode_www_form(params)
          return url
        end
      end
    end
  end
end
