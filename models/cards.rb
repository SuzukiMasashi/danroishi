class Card < Model
  include CardClassEnumerations
  include CardSetEnumerations
  include CardTypeEnumerations
  include RaceEnumerations
  include RarityEnumerations

  has_many :collection_cards
  has_many :collections, through: :collection_cards

  attr_accessor :code,
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
end
