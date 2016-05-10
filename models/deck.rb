class Deck < Model
  belongs_to :collection
  has_many   :deck_cards

  attr_accessor :status,
                :hero,
                :quantity_of_minion,
                :quantity_of_spell,
                :quantity_of_weapon

  def valid_hero?
    classes = deck_cards.pluck(:card_class).uniq

    classes == (classes & [hero, "NEUTRAL"])
  end

  def total_legendary
    deck_cards.where(rarity: "LEGENDARY").sum(:quantity)
  end

  def total_epic
    deck_cards.where(rarity: "EPIC").sum(:quantity)
  end

  def total_rare
    deck_cards.where(rarity: "RARE").sum(:quantity)
  end

  def total_common
    deck_cards.where(rarity: "COMMON").sum(:quantity)
  end

  def total
    deck_cards.sum(:quantity)
  end
end
