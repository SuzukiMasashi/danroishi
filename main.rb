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

  # デッキ生成
  service = DeckService.create(service.collection)
  service.create_deck

  # レギュレーションチェック
  if service.valid?
    "OK！デッキに問題ありませんでした。".tapp
    service.export_deck
  else
    "デッキにレギュレーション違反がありました。".tapp
  end
end
