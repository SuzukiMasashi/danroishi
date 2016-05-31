class CollectionService
  class << self
    def create
      Dotenv.load ".env.collection"

      card_set   = ENV["COLLECTION_CARD_SET"].tr(" ", "")

      card_class =
        if ENV["CARD_CLASS"].present?
          ENV["CARD_CLASS"]
        else
          "NEUTRAL,DRUID,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR"
        end

      header               = ENV["COLLECTION_HEADER"].tr(" ", "")
      highlander           = ENV["HIGHLANDER"].squish
      collection_file_path = ENV["COLLECTION_FILE_PATH"].squish

      new(card_set, card_class, header, highlander, collection_file_path)
    end
  end

  attr_reader :collection

  def initialize(card_set, card_class, header, highlander, collection_file_path)
    @card_sets            = card_set.split(",")
    @card_classes         = card_class.split(",")
    @headers              = header.split(",").map(&:to_sym)
    @highlander           = highlander.inquiry.true?
    @collection_file_path = collection_file_path

    @collection = Collection.create(card_set: card_set, card_class: card_class, highlander: highlander?)
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
      next unless @card_sets.include?(card.card_set) && @card_classes.include?(card.card_class)

      CollectionCard.create(
        collection_id: @collection.id,
        card_id:       card.id,
        quantity:      quantity(card.rarity)
      )
    end
  end

  def export_collection
    if @collection.cards.count.zero?
      create_collection
    end

    CSV.open(@collection_file_path, "wb", headers: @headers + [:quantity], write_headers: true) do |csv|
      @collection.collection_cards.each do |collection_card|
        card_params = collection_card.card.to_h.values_at(*@headers)
        quantity    = collection_card.quantity

        csv << card_params.push(quantity)
      end
    end
  end
end
