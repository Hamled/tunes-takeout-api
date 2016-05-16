require 'mongoid'

module TunesTakeout
  class Favorite
    include Mongoid::Document

    field :user_id, type: String
    belongs_to :suggestion

    validates :user_id, presence: true

    index({ user_id: 1 })
    index({ user_id: 1, suggestion_id: 1 }, { unique: true })

    def self.suggestions_for_user(user_id)
      begin
        Favorite.includes(:suggestion).where(user_id: user_id).map(&:suggestion)
      rescue Mongoid::Errors::DocumentNotFound
        []
      end
    end

    def self.favorite_suggestion(user_id, suggestion)
      begin
        raise Errors::NotFound unless suggestion

        Favorite.create!(user_id: user_id, suggestion: suggestion)
      rescue Mongo::Error::OperationFailure => ex
        if ex.message =~ /^E11000/
          raise Errors::AlreadyExists
        else
          raise ex
        end
      end
    end
  end
end
