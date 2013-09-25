class Order < ActiveRecord::Base

  # == CONSTANTS
  STATUSES = {'OR' => 'Order', 'O' => 'Shipped', 'C' => 'Paid'}

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
    po_number quoted: "PO Number"
    order_date to_date: "Order Date"
    due_date   to_date: "Promise Date"
    trucking_co_assigned "Trucking Company"
  end

  comma :status_report do
    company_name
    plant
    invoice_number quoted: "Invoice Number"
    po_number quoted: "PO Number"
    due_date to_date: "Promise Date"
    status_text "Status"
  end

  # == Scopes
  scope :lines,         select('DISTINCT business_line')
  scope :last_quarter,  lambda { where('order_date > ?', Date.today - 150) }
  scope :orders,        where(:status => 'OR')
  scope :sales,         where(:status => %w(O C))

  # Menards & Blains and Country Stone  are on year 2011
  # Colorado Lava and Green Thumb of GA are on year 2010
  scope :primary_companies,
        where(company_name: ['Country Stone', 'Colorado Lava', 'Menards&Blains', 'Green Thumb of Georgia', 'Infinity Fertilizers'])

  # == HELPERS
  def status_text
    STATUSES[self.status]
  end

end
