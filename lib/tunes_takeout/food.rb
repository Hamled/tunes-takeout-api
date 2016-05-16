require 'yelp'
require 'mongoid'

module TunesTakeout
  class Food
    include Mongoid::Document

    field :yelp_id, type: String
    has_many :suggestions

    validates :yelp_id, presence: true

    index({ yelp_id: 1 }, { unique: true })

    YELP_LIMIT_MAX = 20
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
      offset = 0
      results = []
      while limit > 0
        resp = client.search(DEFAULT_LOCATION, {
          term: query,
          limit: [limit, YELP_LIMIT_MAX].min,
          offset: offset,
          category: DEFAULT_CATEGORY
        })

        results.concat(resp.businesses.map do |business|
          find_or_create_by_business(business)
        end.to_a)

        limit -= YELP_LIMIT_MAX
        offset += YELP_LIMIT_MAX
      end

      return results.sort_by(&:yelp_id)
    end

    def self.find_or_create_by_business(business)
      Food.find_or_create_by({ yelp_id: business.id })
    end
  end
end