class Production < ActiveRecord::Base

  # == ATTRIBUTES
  attr_accessor :kind, :group

  # == ASSOCIATIONS
  belongs_to  :facility
  belongs_to  :product

  # == CALLBACKS
  after_save :update_current_inventory


  protected

  def update_current_inventory
    product.save
  end

end
