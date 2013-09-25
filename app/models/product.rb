class Product < ActiveRecord::Base

  # == ATTRIBUTES
  attr_accessor :facility_id
  attr_accessor :results # for reports

  # == ASSOCIATIONS
  belongs_to  :facility
  has_many    :productions
  has_many    :order_items

  # == SCOPES
  scope :groups, select("DISTINCT [group]")
  scope :types, select("DISTINCT kind")
  scope :facilities,    select('DISTINCT facility_name')

  scope :between_dates, lambda {|start, stop, start2, stop2|
    where('([order_items].[due_date] BETWEEN ? AND ?) OR ([order_items].[due_date] BETWEEN ? AND ?)',
      start, stop, start2, stop2)
  }

  # == CALLBACKS
  before_save :update_inventory
  before_save :set_facility_name

  # == INVENTORY
  def update_inventory
    quantity  = productions.sum(:produced_quantity)
    quantity -= order_items.primary_companies.sales.inventory_start.sum(:quantity)

    self.current_inventory = quantity
  end

  def set_on_hand(amount)
    self.update_inventory
    amount -= self.current_inventory
    return if amount == 0

    self.productions.create(facility: self.facility, scrap_quantity: 0, produced_quantity: amount,
      item_number: self.item_number, pallet_quantity: amount / self.pallet_quantity,
      description: self.description, inventory_entry: true)

    self.save
  end

  # == HELPERS
  def full_name
    "#{self.item_number} - #{self.description}"
  end

  def pallet_count(num)
    (num / self.pallet_quantity).floor
  end

  def available_count(num)
    self.current_inventory - num
  end

  def pallets_on_hand
    pallet_count(self.current_inventory)
  end

  def pallets_available
    pallet_count(self.available)
  end

  def pallets_on_demand(bu = nil)
    pallet_count(self.demand(bu))
  end

  def quoted_item_number
    "=\"#{self.item_number}\""
  end

  def pallet_quantity
    qty = self.read_attribute :pallet_quantity
    qty == 0 ? 1 : qty
  end

  # == REPORTING FUNCTIONS
  def demand(bu = nil)
    qry = order_items.last_quarter.primary_companies.orders
    qry = qry.where(business_line: bu) if bu
    qry.sum(:quantity)
  end

  def available(bu = nil)
    current_inventory - demand(bu)
  end

  def sales(scope = :scoped)
    qry = order_items.sales.primary_companies.send(scope)

    if facility_id
      fac = Facility.find(facility_id)
      qry = qry.where(plant: fac.name)
    end

    order_items.sum(:quantity)
  end

  protected
    def set_facility_name
      self.facility_name = facility.try(:name)
    end

end
