class CollectionService
  class << self
    def create
      new(ENV['CARD_SETS'], ENV['HiGHLANDER'])
    end
  end

  def initialize(card_sets, highlander)
    @card_sets  = card_sets.split(',')
    @highlander = highlander
    @collection = Collection.create(card_sets: card_sets, highlander: highlander?)
  end

  def highlander?
    !!@highlander
  end

  def quantity(rarity)
    return 1 if highlander? || rarity == 'LEGENDARY'

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
      next unless @card_sets.include?(card.card_set)

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

    CSV.open("list.csv", "wb", headers: export_headers.push(:quantity), write_headers: true) do |csv|
      @collection.collection_cards.each do |collection_card|
        card_params = collection_card.card.to_h.values_at(*export_headers)
        quantity    = collection_card.quantity

        csv << card_params.push(quantity)
      end
    end
  end

  private

  def export_headers
    %i(card_class cost name)
  end
end
