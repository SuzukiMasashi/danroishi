class Card < Model
  include CardClassEnumerations
  include CardSetEnumerations
  include CardTypeEnumerations
  include RaceEnumerations
  include RarityEnumerations

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
