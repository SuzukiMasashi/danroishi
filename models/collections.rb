class Collection < Model
  has_many :collection_cards
  has_many :cards, through: :collection_cards

  attr_accessor :card_sets,
                :highlander
end
