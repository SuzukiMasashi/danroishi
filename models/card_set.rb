class CardSet
  include CardSetEnumeration

  class << self
    def disabled_sets
      %w(INVALID TEST_TEMPORARY MISSIONS DEMO NONE CHEAT BLANK DEBUG_SP CREDITS HERO_SKINS TB SLUSH OG_RESERVE)
    end

    def out_of_sets
      %w(REWARD PROMO NAXX GVG)
    end

    def wild
      card_set.values - disabled_sets
    end

    def standard
      wild - out_of_sets
    end
  end
end
