class CardClass
  include CardClassEnumerations

  class << self
    def disabled_classes
      %w(DEATHKNIGHT DREAM COUNT)
    end

    def enabled_classes
      %w(NEUTRAL)
    end

    def collectible_classes
      card_class.values - disabled_classes
    end

    def hero
      collectible_classes - enabled_classes
    end
  end
end
