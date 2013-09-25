class MeijerSalesReport < ArelReport

  base_table  MeijerPosSale
  remove_zeros

  project :store_num, :store_name, :item_number, :description

  optional_fields :month, :week_num, :check => :week

  before_query :units_and_sales_fields

  protected
  def units_and_sales_fields
    start = Date.parse(@options[:begin_date])
    stop  = Date.parse(@options[:end_date])

    add_aggregate(:ty_units, :sum, :sales_units, :week, start, stop)
    add_aggregate(:ly_units, :sum, :sales_units, :week, start - 1.year, stop - 1.year)
    add_aggregate(:ty_sales, :sum, :sales_dollars, :week, start, stop)
    add_aggregate(:ly_sales, :sum, :sales_dollars, :week, start - 1.year, stop - 1.year)

    add_where(:store_num, :in, @options[:store_number])  if @options[:store_number]
    add_where(:item_number, :in, @options[:item_number]) if @options[:item_number]
  end

end
