class Card < Model
  include CardClassEnumeration
  include CardSetEnumeration
  include CardTypeEnumeration
  include RaceEnumeration
  include RarityEnumeration

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
