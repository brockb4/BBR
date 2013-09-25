class Facility < ActiveRecord::Base

  # == Associations
  has_many    :products
  has_many    :productions
  #has_many    :order_items

end
