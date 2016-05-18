require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/json'
require 'mongoid'
require 'uri'
require 'tilt/erb'

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

    DEFAULT_LIMIT = 20

    namespace '/v1' do
      get '/ping' do
        json data: 'pong'
      end

      namespace '/suggestions' do
        get '/search' do
          query = params['query']
          limit = (params['limit'] || DEFAULT_LIMIT).to_i
          seed = params['seed'] || query

          suggestions = Suggestion.search(query, limit, seed).map(&:serializeable)

          json({
            href: canonical_url({
              query: query,
              limit: limit,
              seed: seed
            }),
            suggestions: suggestions
          })
        end

        get '/top' do
          limit = (params['limit'] || DEFAULT_LIMIT).to_i

          suggestions = Suggestion.top(limit)

          json({
            href: canonical_url({ limit: limit }),
            suggestions: suggestions
          })
        end

        get '/:suggestion_id' do
          begin
            suggestion = Suggestion.find_by_serializeable_id(params['suggestion_id'])

            json({
              href: canonical_url,
              suggestion: suggestion.serializeable
            })
          rescue Errors::NotFound
            halt(404)
          end
        end
      end

      namespace '/users/:user_id' do
        get '/favorites' do
          suggestions = Favorite.suggestions_for_user(params['user_id'])

          json({
            href: canonical_url,
            suggestions: suggestions.map(&:serializeable_id)
          })
        end

        post '/favorites' do
          request.body.rewind
          data = JSON.parse(request.body.read)

          if data['suggestion']
            begin
              suggestion = Suggestion.find_by_serializeable_id(data['suggestion'])
              Favorite.favorite_suggestion(params['user_id'], suggestion)
            rescue Errors::NotFound
              halt(404) # Could not find suggestion
            rescue Errors::AlreadyExists
              halt(409) # Cannot add the same suggestion twice
            end
          else
              halt(400) # No suggestion to favorite
          end

          halt(201) # Successfully created favorite
        end
      end

      helpers do
        def canonical_url(params = nil)
          url = URI(request.url)
          url.query = params ? URI.encode_www_form(params) : nil
          return url.to_s
        end
      end
    end
  end
end
