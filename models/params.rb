class Param
  attr_accessor :hero,
                :card_sets,
                :total_legendary,
                :total_epic,
                :total_rare,
                :total_common

  attr_writer   :highlander

  def initialize
    @hero            = nil
    @card_sets       = CardSet.standard
    @limit_legendary = 1
    @limit_epic      = 2
    @limit_rare      = 2
    @limit_common    = 2
    @total_legendary = nil
    @total_epic      = nil
    @total_rare      = nil
    @total_common    = nil
    @highlander      = nil
  end

  def highlander?
    !!@highlander
  end
end
