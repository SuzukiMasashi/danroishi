class CollectionCard < Model
  belongs_to :collection
  belongs_to :card

  attr_accessor :quantity
end
