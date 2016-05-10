class DeckService
  class << self
    def create(collection)
      new(
        collection,
        ENV["HERO"],
        ENV["DECKFILE_PATH"],
        ENV["TOTAL_LEGENDARY"].to_i,
        ENV["TOTAL_EPIC"].to_i,
        ENV["TOTAL_RARE"].to_i,
        ENV["TOTAL_COMMON"].to_i
      )
    end
  end

  def initialize(
                  collection,
                  hero,
                  deckfile_path,
                  total_legendary,
                  total_epic,
                  total_rare,
                  total_common
                )

    @collection    = collection
    @deck          = Deck.create(collection: @collection, hero: hero)
    @deckfile_path = deckfile_path
    @validators    = {
      total_legendary: create_total_validator(total_legendary),
      total_epic:      create_total_validator(total_epic),
      total_rare:      create_total_validator(total_rare),
      total_common:    create_total_validator(total_common),
      total:           create_total_validator(30)
    }

    @deck_rows     = CSV.read(@deckfile_path, headers: :first_row)
  end

  def create_deck
    @deck_rows.each do |cols|
      card = @collection.find_card_by_name(cols["name"])
      params = {deck: @deck}.merge(card.to_h.except(:collection_card_ids, :collection_ids)).merge(quantity: cols["quantity"].to_i)
      DeckCard.create(params)
    end
  end

  def valid?
    # Validate Hero
    return false unless @deck.valid_hero?

    # Validate total
    return false unless
                  @validators.keys.all? do |key|
                    next(true) unless validator = @validators[key]

                    validator[@deck.send(key)]
                  end

    true
  end

  def export_deck
    CSV.open(export_deckfile_path, "wb", headers: export_headers, write_headers: true) do |csv|
      @deck.deck_cards.each do |deck_card|
        csv << deck_card.to_h.values_at(*export_headers)
      end
    end
  end

  private

  def create_total_validator(total)
    unless total.zero?
      ->(n) { n <= total }
    end
  end

  def export_deckfile_path
    "valid_#{File.basename(@deckfile_path, '.*')}.csv"
  end

  def export_headers
    DeckCard.export_headers
  end
end
