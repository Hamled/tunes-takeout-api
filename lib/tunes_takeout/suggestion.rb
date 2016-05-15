require 'digest'

module TunesTakeout
  class Suggestion
    attr_reader :food_id, :music_id, :music_type

    def initialize(food, music)
      @food_id = food.id
      @music_id = music.id
      @music_type = music.type
    end

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
        Suggestion.new(foods[n], music[n])
      end
    end

    def to_h
      {
        food_id: food_id,
        music_id: music_id,
        music_type: music_type
      }
    end

    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end
