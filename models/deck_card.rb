class DeckCard < Model
  belongs_to :deck

  attr_accessor :quantity,
                :code,
                :cost,
                :name,
                :card_class,
                :card_set,
                :card_type,
                :race,
                :rarity,
                :collectible,
                :card_text,
                :attack,
                :health,
                :durability

  class << self
    def export_headers
      %i(card_class rarity cost name quantity)
    end
  end
end
