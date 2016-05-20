require 'digest'
require 'mongoid'
require 'base64'

module TunesTakeout
  class Suggestion
    include Mongoid::Document

    belongs_to :food, index: true
    belongs_to :music, index: true
    has_many :favorites

    validates :food_id, presence: true
    validates :music_id, presence: true

    index({ food_id: 1, music_id: 1 }, { unique: true })

    API_SEARCH_LIMIT = 100

    def self.search(query, limit, seed)
      # Get sorted results from both APIs
      foods = Food.search(query, API_SEARCH_LIMIT)
      music = Music.search(query, API_SEARCH_LIMIT)

      # Randomly shuffle them
      random = Random.new(Digest::SHA1.hexdigest(seed).to_i(16))

      foods.shuffle!(random: random)
      music.shuffle!(random: random)

      # Create suggestion pairs
      num_suggestions = [foods, music, 0...limit].map(&:size).min
      (0...num_suggestions).map do |n|
        Suggestion.find_or_create_by({
          food: foods[n],
          music: music[n]
        })
      end
    end

    # Get a list of the top `limit` suggestions,
    # ranked by number of favorites
    def self.top(limit)
      Favorite.collection.aggregate([
        {
          "$group" => {
            _id: "$suggestion_id",
            favorites: { "$sum" => 1 }
          }
        },
        {
          "$sort" => { favorites: -1 }
        },
        {
          "$limit" => limit
        }
      ]).map { |doc| doc["_id"] }.map do |id|
        Suggestion.to_serializeable_id(id.to_s)
      end
    end

    def self.find_by_id(suggestion_id)
      begin
        id = Suggestion.from_serializeable_id(suggestion_id)
        Suggestion.find(id)
      rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
        raise Errors::NotFound
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

    def serializeable_id
      Suggestion.to_serializeable_id(_id)
    end

    # Get a URL-safe, short encoding of the document ID
    def self.to_serializeable_id(id)
      begin
        Base64.urlsafe_encode64([id].pack('H*'))
      rescue ArgumentError
        return nil
      end
    end

    # Get document ID from URL-safe, short encoding
    def self.from_serializeable_id(id)
      begin
        Base64.urlsafe_decode64(id).unpack('H*').first
      rescue ArgumentError
        return nil
      end
    end
  end
end
