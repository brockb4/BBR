class RoyaltyCompany < ActiveRecord::Base

  # == ASSOCIATIONS
  has_many :royalty_items

  accepts_nested_attributes_for :royalty_items, allow_destroy: true, reject_if: :all_blank

end
