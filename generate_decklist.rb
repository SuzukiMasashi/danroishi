require 'active_support'
require 'active_support/core_ext'
require 'csv'
require 'bundler'
Bundler.require

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
  MANA_COST_RANGE  = 0..25
  HIGHLANDER       = true
  HEROES           = %w(DRUID HUNTER MAGE PALADIN PRIEST ROGUE SHAMAN WARLOCK WARRIOR)
  LIMIT_DECK_QTY   = 30
  LIMIT_CARD_QTY   = HIGHLANDER ? (1..1) : (1..2)

  # Highline Client
  cli  = HighLine.new

  # 全カードデータ生成
  service = CardsService.create
  service.create_cards

  # ヒーロー選択

  hero = cli.choose do |menu|
    menu.echo    = true
    menu.prompt  = "ヒーローは？  "
    menu.choice("** ヒーロー未選択 **")
    menu.choices(*HEROES)
  end
  cli.say("[#{hero}]を選択しました。")

  # カード選択
  cards = 1.upto(LIMIT_DECK_QTY).map do |n|
    # カードセット
    # クエリを実行すると破壊的に更新されてしまうため都度カードを抽出する
    relations = if hero == "** ヒーロー未選択 **"
                  [
                    Card.where(card_set: "CORE"),
                    Card.where(card_set: "EXPERT1").where(rarity: %w(COMMON RARE)),
                    Card.where(card_set: "OG")
                  ]
                else
                  [
                    Card.where(card_class: [hero, "NEUTRAL"]).where(card_set: "CORE"),
                    Card.where(card_class: [hero, "NEUTRAL"]).where(card_set: "EXPERT1").where(rarity: %w(COMMON RARE)),
                    Card.where(card_class: [hero, "NEUTRAL"]).where(card_set: "OG")
                  ]
                end

    # コスト
    cost  = cli.ask('コストは？  ', Integer) {|q| q.in = MANA_COST_RANGE }
    names = relations.flat_map {|relation| relation.where(cost: cost).pluck(:name) }
    if names.count.zero?
      cli.say("該当するカードはありません。")
      redo
    end

    # 名前
    name = cli.choose do |menu|
      menu.echo    = true
      menu.prompt  = "カード名は？  "
      menu.choice("** コスト再選択 **")
      menu.choices(*names)
    end
    redo if name == "** コスト再選択 **"
    cli.say("[#{name}]を1枚登録しました。")

    # カード
    Card.find_by(name: name)
  end

  # レギュレーションチェック
  # 枚数
  unless cards.count == LIMIT_DECK_QTY
    cli.say("【エラー】")
    cli.say("【エラー】デッキの枚数が#{LIMIT_DECK_QTY}枚ではありません。")
    cli.say("【エラー】終了します。最初からやり直してください。")
    exit(0)
  end

  # クラス
  classes = cards.uniq {|card| card.card_class }
  hero    = classes.map(&:card_class) - %w(NEUTRAL)
  unless (0..1).cover?(hero.count)
    cli.say("【エラー】")
    cli.say("【エラー】デッキのカードクラスが中立以外に複数存在しております。")
    cli.say("【エラー】終了します。最初からやり直してください。")
    exit(0)
  end

  # カード詳細
  card_params    = cards.group_by {|card| card.name }
  condition      = Hash.new { |h,k| h[k] = Hash.new { 0 } }
  error_messages = []
  card_params.each do |name, cards|
    # 枚数
    qty = cards.count
    error_messages.push("【エラー】デッキに[#{name}]が#{qty}枚存在します。") unless LIMIT_CARD_QTY.cover?(qty)

    # レアリティ
    rarity = cards.first.rarity
    error_messages.push("【エラー】デッキに[#{name}]が#{qty}枚存在します。") if (rarity == "LEGENDARY" && qty > 1)

    # セット
    card_set = cards.first.card_set
    condition[card_set][rarity] += qty
    error_messages |= ["【エラー】デッキにクラッシクのレアが#{condition['EXPERT1']['RARE']}枚存在します。"] if condition["EXPERT1"]["RARE"] > 2

    nil
  end
  unless error_messages.empty?
    cli.say("【エラー】")
    cli.say(error_messages.join("\n"))
    cli.say("【エラー】終了します。最初からやり直してください。")
    exit(0)
  end

  # デッキリスト作成
  # コスト別カード
  cards_by_cost = cards.group_by(&:to_h)
                       .map {|card, cards| [card[:cost], card[:name], cards.count, card[:card_set], card[:rarity]] }
                       .group_by {|card| card[0] }

  # デッキリスト
  deck_list = [*MANA_COST_RANGE].each.with_object([]) do |cost, list|
                next if (cards = cards_by_cost[cost]).nil?
                list.concat(cards_by_cost[cost])
              end

  # デッキリスト出力
  current_time = Time.now
  epoch        = current_time.to_i
  usec         = current_time.usec
  File.open("#{epoch}+#{usec}.csv", "w+") do |fp|
    deck_list.each do |card|
      fp.puts card.to_csv
    end
  end
end
