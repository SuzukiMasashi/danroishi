class CardsService
  class << self
    def create
      Dotenv.load ".env.api"

      header          = ENV["CARDS_HEADER"].tr(" ", "")
      cards_file_path = ENV["CARDS_FILE_PATH"].squish

      new(fetch_cards_json, header, cards_file_path)
    end

    private

    def cards_json_url

      [
        ENV["API_HOSTNAME"],
        ENV["API_VERSION"],
        ENV["API_VERSION_LATEST_DIR"],
        ENV["API_LANGUAGE"],
        ENV["CARDS_COLLECTIBLE_JSON"]
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

  def initialize(json, header, cards_file_path)
    @cards           = JSON.load(json).reject {|card| card["type"] == "HERO" }
    @headers         = header.split(",").map(&:to_sym)
    @cards_file_path = cards_file_path
  end

  def sorted_cards
    @cards.sort_by do |card|
      [card["playerClass"] || "", card["cost"], card["set"], card["rarity"], card["name"]]
    end
  end

  def delete_cards
    Card.destroy_all
  end

  def create_cards
    delete_cards

    sorted_cards.each do |card|
      Card.create(
        code:        card["id"],
        cost:        card["cost"],
        name:        card["name"],
        card_class:  card["playerClass"] || "NEUTRAL",
        card_set:    card["set"],
        card_type:   card["type"],
        race:        card["race"],
        rarity:      card["rarity"],
        collectible: card["collectible"],
        card_text:   card["text"].present? ? card["text"].tr("\n", "") : "",
        attack:      card["attack"],
        health:      card["health"],
        durability:  card["durability"],
      )
    end
  end

  def export_cards
    if Card.count.zero?
      create_cards
    end

    CSV.open(@cards_file_path, "wb", headers: @headers, write_headers: true) do |csv|
      Card.each do |card|
        csv << card.to_h.values_at(*@headers)
      end
    end
  end
end
