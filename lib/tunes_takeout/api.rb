require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/json'
require 'mongoid'
require 'dalli'
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

      # Prefer memcachier-prefixed env vars if they exist (in production)
      # Otherwise use generic memcache-prefixed env vars
      config = [:servers, :username, :password].map do |var|
        value = %w(MEMCACHIER MEMCACHE).map do |prefix|
          ENV["#{prefix}_#{var.upcase}"]
        end.compact.first

        [var, value]
      end.to_h.merge({
        failover: (ENV['MEMCACHE_FAILOVER'] || "").downcase == 'true',
        socket_timeout: 1.5,
        socket_failure_delay: 0.2,
        compress: true,
        namespace: "tunes_takeout_api_v1"
      })

      set(:cache_client, Proc.new do
        Dalli::Client.new(config[:servers].split(','), config.except(:servers))
      end)
    end

    LIMIT_DEFAULT = 20
    LIMIT_MAX = 100

    namespace '/v1' do
      get '/ping' do
        json data: 'pong'
      end

      namespace '/suggestions' do
        get '/search' do
          query = params['query']
          limit = (params['limit'] || LIMIT_DEFAULT).to_i
          seed = params['seed'] || query

          halt(400) unless query && limit > 0 && limit <= LIMIT_MAX && seed

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
          limit = (params['limit'] || LIMIT_DEFAULT).to_i
          halt(400) unless limit > 0 && limit <= LIMIT_MAX

          suggestions = Suggestion.top(limit)

          json({
            href: canonical_url({ limit: limit }),
            suggestions: suggestions
          })
        end

        get '/:suggestion_id' do
          begin
            suggestion = Suggestion.find_by_id(params['suggestion_id'])

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
          suggestion_id = parse_body('suggestion')
          halt(400) unless suggestion_id && !suggestion_id.empty?
          begin
            suggestion = Suggestion.find_by_id(suggestion_id)
            faved = Favorite.favorite_suggestion(params['user_id'], suggestion)

            if faved
              halt(201) # Successfully created favorite
            else
              halt(500) # Unknown failure to create favorite
            end
          rescue JSON::ParserError
            halt(400) # Ill-formed JSON document
          rescue Errors::NotFound
            halt(404) # Could not find suggestion
          rescue Errors::AlreadyExists
            halt(409) # Cannot add the same suggestion twice
          end
        end

        delete '/favorites' do
          suggestion_id = parse_body('suggestion')
          halt(400) unless suggestion_id && !suggestion_id.empty?
          begin
            suggestion = Suggestion.find_by_id(suggestion_id)
            unfaved = Favorite.unfavorite_suggestion(params['user_id'], suggestion)

            if unfaved
              halt(204) # No content, successfully deleted
            else
              halt(500) # Unknown failure to delete favorite
            end
          rescue JSON::ParserError
            halt(400) # Ill-formed JSON document
          rescue Errors::NotFound
            halt(404) # Could not find suggestion
          end
        end

        helpers do
          def parse_body(key)
            begin
              request.body.rewind
              data = JSON.parse(request.body.read)

              # We have no requests with bodies that aren't hashes
              halt(400) unless data.class == Hash

              data[key]
            rescue JSON::ParserError
              halt(400) # Ill-formed JSON document
            end
          end
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
