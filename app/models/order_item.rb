class OrderItem < ActiveRecord::Base

  set_primary_key :invoice_number

  # == Comma
  comma do
    company_name
    plant
    business_line
    customer_name
    city "Customer City"
    state "Customer State"
    zip_code "Customer Zipcode"
    invoice_number
    po_number "PO Number"
    order_date to_date: "Order Date"
    due_date   to_date: "Promise Date"
    trucking_co_assigned "Trucking Company"
    product group: "Product Group"
    product kind: "Product Type"
    product :pallet_quantity
    item_number quoted: "Item Number"
    item_name "Item Name"
    quantity
    pallet_quantity "# of Pallets"
    item_subtotal "Amount"
  end

  # == Associations
  belongs_to :product

  #  == Scopes
  scope :this_month,    lambda {
                          where('YEAR(order_date) = ? AND MONTH(order_date) = ?', Date.today.year, Date.today.month)}
  scope :last_quarter,  lambda { where('due_date > ?', Date.today - 150) }
  scope :orders,        where(:status => 'OR')
  scope :sales,         where(:status => %w(O C))
  scope :inventory_start, where('due_date > ?', '2010-12-20')
  scope :primary_companies,
        where(company_name: ['Country Stone', 'Colorado Lava', 'Menards&Blains', 'Green Thumb of Georgia', 'Infinity Fertilizers'])

  # == CLASS METHODS
  class << self
    def business_line
      distinct_values(:business_line) - ['Internal']
    end

    def customer_name
      distinct_values(:customer_name)
    end

    def plant
      distinct_values(:plant)
    end

    def product_group
      distinct_values(:product_group)
    end

    def product_type
      distinct_values(:product_type)
    end

    def states
      distinct_values(:state)
    end

    protected
    def distinct_values(field)
      select("DISTINCT #{field}").order(field).all.collect {|x| x.send(field)}
    end
  end

  # == INSTANCE METHODS
  def pallet_quantity
    prod = self.product || Product.where(item_number: self.item_number).first
    prod ? (self.quantity / prod.pallet_quantity) : '?'
  end
end
