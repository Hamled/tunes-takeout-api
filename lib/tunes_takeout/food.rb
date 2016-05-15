require 'yelp'

module TunesTakeout
  class Food
    DEFAULT_LOCATION = "Seattle"
    DEFAULT_CATEGORY = "food"

    attr_reader :id

    def initialize(business)
      @id = business.id
    end

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
        Food.new(business)
      end.sort_by(&:id).take(limit)
    end
  end
end
