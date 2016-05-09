require 'bundler'
Bundler.require

require 'csv'

# Enum
Dir[File.expand_path("../enumerations/", __FILE__) << '/*.rb'].each do |file|
  require file
end

# PassiveRecord Model
class Model
  include PassiveRecord
end

# Model
Dir[File.expand_path("../models/", __FILE__) << '/*.rb'].each do |file|
  require file
end

# Services
Dir[File.expand_path("../services/", __FILE__) << '/*.rb'].each do |file|
  require file
end

# main
if __FILE__ == $0
  Dotenv.load ".env.api"
  Dotenv.load ".env"

  # 全カードデータ生成
  service = CardsService.create
  service.create_cards
  # service.export_cards

  # コレクション生成
  service = CollectionService.create
  # service.create_collection
  service.export_list

  # binding.pry
  all = Card.count.tapp
  disabled = Card.where(card_set: CardSet.disabled_sets).count.tapp
  out_of = Card.where(card_set: CardSet.out_of_sets).count.tapp
  standard = Card.where(card_set: CardSet.standard).count.tapp
  CardClass.hero.tapp
end
