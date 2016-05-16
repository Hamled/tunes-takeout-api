require 'mongoid'

module TunesTakeout
  class Favorite
    include Mongoid::Document

    field :user_id, type: String
    belongs_to :suggestion

    validates :user_id, presence: true

    index({ user_id: 1 })
    index({ user_id: 1, suggestion_id: 1 }, { unique: true })
  end
end
