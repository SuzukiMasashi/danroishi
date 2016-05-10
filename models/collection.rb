class Collection < Model
  has_many :collection_cards
  has_many :cards, through: :collection_cards

  attr_accessor :card_sets,
                :card_class,
                :highlander

  def find_card_by_name(name)
    # なぜか動かいない
    # _cards = self.cards.where(name: name)

    # return false unless _cards.count == 1

    # _cards.first

    _cards = Card.where(name: name)

    return false unless _cards.count == 1

    if self.collection_cards.where(card_id: _cards.first.id).count == 1
      _cards.first
    else
      false
    end
  end
end
