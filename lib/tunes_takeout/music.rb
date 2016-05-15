require 'rspotify'

module TunesTakeout
  class Music
    TYPES = [RSpotify::Artist, RSpotify::Album,
             RSpotify::Track, RSpotify::Playlist]

    attr_reader :id, :type

    def initialize(item)
      @id = item.id
      @type = item.type
    end

    def self.search(query, limit)
      TYPES.map do |type|
        type.search(query, limit: limit).map do |item|
          Music.new(item)
        end
      end.flatten.sort_by(&:id).take(limit)
    end
  end
end
