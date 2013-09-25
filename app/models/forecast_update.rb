class ForecastUpdate < ActiveRecord::Base

  # == CALLBACKS
  before_save :set_current_plant_if_not_set

  # == SCOPES
  scope :live,     where(:unlive => false)
  scope :not_live, where(:unlive => true)

  # == CLASS METHODS
  class << self
    def find_for(data, with_customer=true)
      return unless data[:business_line]
      qry = where(:current_plant => data[:plant], :business_line => data[:business_line], :item_number => data[:item_number])

      if data[:customer_name] && with_customer
        qry = qry.where(:customer => data[:customer_name])
      else
        qry = qry.where(:customer => nil)
      end

      qry.first
    end

    def business_line
      (OrderItem.business_line + self.select("DISTINCT business_line").all.map(&:business_line)).uniq.compact.sort
    end
  end

  # == INSTANCE METHODS
  def in_program
    read_attribute(:in_program) == 1
  end

  # == PROTECTED METHODS
  protected
  def set_current_plant_if_not_set
    self.current_plant = future_plant unless current_plant.present?
  end
end
