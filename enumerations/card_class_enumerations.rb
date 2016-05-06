module CardClassEnumerations
  extend Enumerize

  enumerize :card_class, in: {
    :'NEUTRAL'     => 0,
    :'DEATHKNIGHT' => 1,
    :'DRUID'       => 2,
    :'HUNTER'      => 3,
    :'MAGE'        => 4,
    :'PALADIN'     => 5,
    :'PRIEST'      => 6,
    :'ROGUE'       => 7,
    :'SHAMAN'      => 8,
    :'WARLOCK'     => 9,
    :'WARRIOR'     => 10,
    :'DREAM'       => 11,
    :'COUNT'       => 12,
  }
end
