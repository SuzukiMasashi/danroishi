class CardsService
  class << self
    def create
      new(fetch_cards_json)
    end

    private

    def cards_json_url
      [
        ENV['API_HOSTNAME'],
        ENV['API_VERSION'],
        ENV['API_VERSION_LATEST_DIR'],
        ENV['API_LANGUAGE'],
        ENV['CARDS_COLLECTIBLE_JSON']
      ].join("/")
    end

    def fetch_cards_json
      RestClient::Resource.new(
        cards_json_url,
        verify_ssl: OpenSSL::SSL::VERIFY_NONE
      ).get
    rescue => e
      e.response
    end
  end

  def initialize(json)
    @cards = JSON.load(json)
  end

  def delete_cards
    Card.destroy_all
  end

  def create_cards
    delete_cards

    @cards.each do |card|
      Card.create(
        code:        card['id'],
        cost:        card['cost'],
        name:        card['name'],
        card_class:  card['playerClass'] || 'NEUTRAL',
        card_set:    card['set'],
        card_type:   card['type'],
        race:        card['race'],
        rarity:      card['rarity'],
        collectible: card['collectible'],
        card_text:   card['text'],
        attack:      card['attack'],
        health:      card['health'],
        durability:  card['durability'],
      )
    end
  end

  def export_cards
    if Card.count.zero?
      create_cards
    end

    CSV.open("cards.csv", "wb", headers: export_headers, write_headers: true) do |csv|
      Card.each do |card|
        csv << card.to_h.values_at(*export_headers)
      end
    end
  end

  private

  def export_headers
    %i(cost name card_class card_set card_type race rarity card_text attack health durability)
  end
end
