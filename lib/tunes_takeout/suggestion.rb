require 'digest'
require 'mongoid'
require 'base64'

module TunesTakeout
  class Suggestion
    include Mongoid::Document

    belongs_to :food, index: true
    belongs_to :music, index: true

    validates :food_id, presence: true
    validates :music_id, presence: true

    index({ food_id: 1, music_id: 1 }, { unique: true })

    def self.search(query, limit, seed)
      # Get sorted results from both APIs
      foods = Food.search(query, limit)
      music = Music.search(query, limit)

      # Randomly shuffle them
      random = Random.new(Digest::SHA1.hexdigest(seed).to_i(16))

      foods.shuffle!(random: random)
      music.shuffle!(random: random)

      # Create suggestion pairs
      num_suggestions = [foods, music].map(&:length).min
      (0...num_suggestions).map do |n|
        Suggestion.find_or_create_by({
          food: foods[n],
          music: music[n]
        })
      end
    end

    def serializeable
      {
        id: serializeable_id,
        food_id: food.yelp_id,
        music_id: music.spotify_id,
        music_type: music.spotify_type
      }
    end

    # Get a URL-safe, short encoding of the document ID
    def serializeable_id
      Base64.urlsafe_encode64([_id].pack('H*'))
    end
  end
end
