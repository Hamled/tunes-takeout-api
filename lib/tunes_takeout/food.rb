require 'yelp'
require 'mongoid'

module TunesTakeout
  class Food
    include Mongoid::Document

    field :yelp_id, type: String
    has_many :suggestions

    validates :yelp_id, presence: true

    index({ yelp_id: 1 }, { unique: true })

    DEFAULT_LOCATION = "Seattle"
    DEFAULT_CATEGORY = "food"

    def self.client
      @client ||= Yelp::Client.new({
        consumer_key: ENV['YELP_CONSUMER_KEY'],
        consumer_secret: ENV['YELP_CONSUMER_SECRET'],
        token: ENV['YELP_TOKEN'],
        token_secret: ENV['YELP_TOKEN_SECRET']
      })
    end

    def self.search(query, limit)
      resp = client.search(DEFAULT_LOCATION, {
        term: query,
        limit: limit,
        category: DEFAULT_CATEGORY
      })

      resp.businesses.map do |business|
        find_or_create_by_business(business)
      end.sort_by(&:yelp_id).take(limit)
    end

    def self.find_or_create_by_business(business)
      Food.find_or_create_by({ yelp_id: business.id })
    end
  end
end
