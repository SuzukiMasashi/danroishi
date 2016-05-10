module RarityEnumeration
  extend Enumerize

  enumerize :rarity, in: {
    :'INVALID'   => 0,
    :'COMMON'    => 1,
    :'FREE'      => 2,
    :'RARE'      => 3,
    :'EPIC'      => 4,
    :'LEGENDARY' => 5,
  }
end
