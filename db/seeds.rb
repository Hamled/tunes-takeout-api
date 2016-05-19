require 'dotenv'
Dotenv.load!

require 'mongoid'
require './lib/tunes_takeout'

Mongoid.load! 'config/mongoid.yml'
Mongoid.logger.level = :warn

print "Purging database... "
Mongoid::Config.purge!
puts "done."

# Create a bunch of suggestions
print "Creating suggestions... "

QUERIES = %w(banana tacos pie)
LIMIT = 100

sugs = []
QUERIES.each do |query|
  sugs.concat TunesTakeout::Suggestion.search(query, LIMIT, query)
end

puts "done. (#{sugs.size} suggestions)"


# Create a bunch of favorites
print "Creating favorites... "

USERS = %w(shakira beyonce jay-z thrice teagan sara some-jerk)

favs_created = sugs.map do |suggestion|
  USERS.shuffle.take(rand(USERS.size)).map do |user|
    TunesTakeout::Favorite.favorite_suggestion(user, suggestion)
  end.size
end.reduce(&:+)

puts "done. (#{favs_created} favorites)"

# Create indexes
print "Creating indexes... "

Mongoid::Tasks::Database.create_indexes

puts "done."
