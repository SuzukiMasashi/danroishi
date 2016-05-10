class CollectionService
  class << self
    def create
      new(ENV["CARD_SETS"], ENV["HERO"], ENV["HIGHLANDER"])
    end
  end

  attr_reader :collection

  def initialize(card_sets, card_class, highlander)
    @card_sets  = card_sets.split(",")
    @card_class = card_class.split(",").push("NEUTRAL")
    @highlander = highlander
    @collection = Collection.create(card_sets: card_sets, card_class: @card_class, highlander: highlander?)
  end

  def highlander?
    !!@highlander
  end

  def quantity(rarity)
    return 1 if highlander? || rarity == "LEGENDARY"

    2
  end

  def delete_cards
    @collection.collection_card_ids.each do |collection_card_id|
      CollectionCard.destroy(collection_card_id)
    end
  end

  def create_collection
    delete_cards

    Card.each do |card|
      next unless @card_sets.include?(card.card_set) && @card_class.include?(card.card_class)

      CollectionCard.create(
        collection_id: @collection.id,
        card_id:       card.id,
        quantity:      quantity(card.rarity)
      )
    end
  end

  def export_list
    if @collection.cards.count.zero?
      create_collection
    end

    CSV.open("list.csv", "wb", headers: export_headers, write_headers: true) do |csv|
      @collection.collection_cards.each do |collection_card|
        card_params = collection_card.card.to_h.values_at(*(export_headers - [:quantity]))
        quantity    = collection_card.quantity

        csv << card_params.push(quantity)
      end
    end
  end

  private

  def export_headers
    DeckCard.export_headers
  end
end
