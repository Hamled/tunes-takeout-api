require 'rspotify'
require 'mongoid'

module TunesTakeout
  class Music
    include Mongoid::Document

    field :spotify_id, type: String
    field :spotify_type, type: String
    has_many :suggestions

    validates :spotify_id, presence: true
    validates :spotify_type, presence: true

    validate do
      valid_types = TYPES.map(&:to_s).map { |t| t.split('::').last.downcase }
      if !valid_types.include? spotify_type
        errors.add(:spotify_type, "Must be one of: #{valid_types.join(', ')}.")
      end
    end

    index({ spotify_id: 1, spotify_type: 1 }, { unique: true })

    SPOTIFY_LIMIT_MAX = 50
    TYPES = [RSpotify::Artist, RSpotify::Album, RSpotify::Track]

    CACHE_TTL = 60*60*24*1 # 1 day
    CACHE_KEY_PREFIX = "music_spotify"

    def self.search(query, limit)
      TYPES.map do |type|
        type_limit = limit
        type_offset = 0
        results = []
        while type_limit > 0
          resp = spotify_search(type, {
            query: query,
            limit: [type_limit, SPOTIFY_LIMIT_MAX].min,
            offset: type_offset
          })

          results.concat(resp.map do |item|
            find_or_create_by_spotify_item(item)
          end.to_a)

          type_limit -= SPOTIFY_LIMIT_MAX
          type_offset += SPOTIFY_LIMIT_MAX
        end

        results
      end.flatten.sort_by(&:spotify_id).take(limit)
    end

    def self.find_or_create_by_spotify_item(item)
      Music.find_or_create_by({
        spotify_id: item[:id],
        spotify_type: item[:type]
      })
    end

    private

    def self.spotify_search(type, options)
      cache_key = options.merge(call: "#{CACHE_KEY_PREFIX}_search")
      TunesTakeout::API.settings.cache_client.fetch(cache_key, CACHE_TTL) do
        # We have to map the resulting RSpotify items because they contain
        # singletons which cannot be marshalled for caching
        type.search(options[:query], options.slice(:limit, :offset)).map do |item|
          {
            id: item.id,
            type: item.type
          }
        end
      end
    end
  end
end
