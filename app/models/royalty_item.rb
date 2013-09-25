class RoyaltyItem < ActiveRecord::Base

  # == ASSOCIATIONS
  belongs_to :royalty_company

  # == VALIDATIONS
  validates :item_number, presence: true

  # == CALLBACKS
  before_create :set_description

  # == PROTECTED METHODS
  protected

  def set_description
    item = Product.where(:item_number => self.item_number).first
    item ||= OrderItem.where(:item_number => self.item_number).first
    self.description = item.try(:description)
  end

end
