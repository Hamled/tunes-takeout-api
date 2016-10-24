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

    CACHE_TTL = 60*60*24*1 # 1 day
    CACHE_KEY_PREFIX = "food_yelp"

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
        resp = yelp_search({
          location: DEFAULT_LOCATION,
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

    private

    def self.yelp_search(options)
      cache_key = options.merge(call: "#{CACHE_KEY_PREFIX}_search")
      TunesTakeout::API.settings.cache_client.fetch(cache_key, CACHE_TTL) do
        client.search(options[:location],
                      options.slice(:term, :limit, :offset, :category))
      end
    end
  end
end
