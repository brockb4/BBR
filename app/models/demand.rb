class Demand

  # == CONSTANTS
  GRANULARITY = %w(Daily Weekly Monthly)

  attr_accessor :facility_ids

  # == CLASS METHODS
  def self.facilities
    Product.select('DISTINCT facility_name').order(:facility_name).all.collect {|x| x.facility_name} - ['Unknown']
  end

  def self.business_lines
    Order.select('DISTINCT business_line').order(:business_line).all.collect {|x| x.business_line}
  end

  def self.categories
    Product.select('DISTINCT [group]').order('[group]').all.collect {|x| x.group}
  end

  def self.types
    Product.select('DISTINCT [kind]').order('[kind]').all.collect {|x| x.kind}
  end

  # == MAGIC
  def initialize(options = {})
    @options = options

    @results = Product.joins(:order_items).
      select('DISTINCT [products].*').
      where(order_items: {status: 'OR'}).
      where(order_items: {company_name: ['Country Stone', 'Colorado Lava', 'Menards&Blains', 'Green Thumb of Georgia', 'Infinity Fertilizers']})

    @options[:facilities] ||= Product.facilities.collect {|p| p.facility_name}
    if @options[:facilities].include?('Unavailable')
      @results = @results.where('facility_name IN (?) OR facility_name IS NULL', @options[:facilities])
    else
      @results = @results.where(facility_name: @options[:facilities])
    end

    @results = @results.where(order_items: {business_line: @options[:business_lines]}) if @options[:business_lines]
    @results = @results.where(group: @options[:categories]) if @options[:categories]
    @results = @results.where(kind: @options[:types]) if @options[:types]

    @results = case @options[:granularity]
    when 'Daily'
      @results.where('[order_items].[due_date] BETWEEN ? AND ?',
        Date.parse(@options[:begin_date]), Date.parse(@options[:end_date]))
    when 'Weekly'
      @results.where('[order_items].[due_date] BETWEEN ? AND ?',
        Date.parse(@options[:begin_date]).monday.to_s, Date.parse(@options[:end_date]).sunday.to_s)
    when 'Monthly'
      start = Date.parse(@options[:begin_date])
      stop  = Date.parse(@options[:end_date])
      @results.where('[order_items].[due_date] BETWEEN ? AND ?', start - (start.day-1), (stop >> 1) - stop.day)
    end
  end

  def results
    headers = generate_headers
    @output = []
    process_results(@results)
    @output.sort! {|l, r| l[17] <=> r[17]}
    @output.unshift(headers)
    @output.collect {|x| x.to_csv}.join('')
  end

  protected

  def format_date(d)
    case @options[:granularity]
    when 'Daily'
      {header: d.strftime('%Y-%m-%d'), start: d, stop: d}
    when 'Weekly'
      {header: d.monday.strftime('%Y-%m-%d'), start: d.monday, stop: d.sunday}
    when 'Monthly'
      {header: d.strftime('%Y-%m'), start: d - (d.day-1), stop: (d >> 1) - d.day}
    end
  end

  def advance_date(d)
    case @options[:granularity]
    when 'Daily'
      d + 1
    when 'Weekly'
      d + 7
    when 'Monthly'
      d >> 1
    end
  end

  def generate_headers
    header =  ['Plant', 'Business Line', 'Item #', 'Item Desc', 'Category', 'Type']
    header += ['Pallet Qty', 'On Hand', 'Hand Bags', 'Zip Bags', 'Premier Bags', 'Total On Order']
    header += ['Available', 'Pallets On Hand', 'Pallets On Order']
    header += ['Range On Order', 'Range Pallets On Order', 'Avail Relative to Range']
    header += generate_dates.collect {|d| d[:header]}
    header
  end

  def generate_dates
    @dates = []
    start = Date.parse(@options[:begin_date])
    stop  = Date.parse(@options[:end_date])
    stop_on = format_date(stop)

    loop do
      cur_date = format_date(start)
      @dates << cur_date
      break if cur_date == stop_on || start == stop
      start = advance_date(start)
    end

    @dates
  end

  def process_results(results)
    # == OLD
    results.all.each do |product|
      product.results = {}

      @dates.each do |d|
        qry = product.order_items.orders.primary_companies.where('due_date BETWEEN ? AND ?', d[:start], d[:stop])

        if @options[:business_lines]
          product.results[d[:header]] = qry.group(:business_line).
            where(business_line: @options[:business_lines]).sum(:quantity)
        else
          res = qry.sum(:quantity)
          product.results[d[:header]] = {nil => res > 0 ? res : nil}
        end
      end

      product.results.values.collect(&:keys).flatten.uniq.each do |bu|
        line = [product.facility_name, bu, product.quoted_item_number, product.description, product.group,
          product.kind, product.pallet_quantity, product.current_inventory, product.hand_bags,
          product.zip_bags, product.premier_bags, product.demand(bu), product.available(bu),
          product.pallets_on_hand, product.pallets_on_demand(bu), 0, 0, 0]

        range_demand = 0

        @dates.each do |d|
          range_demand += (product.results[d[:header]][bu] || 0)
          line << product.results[d[:header]][bu]
        end

        line[15] = range_demand
        line[16] = product.pallet_count(range_demand)
        line[17] = product.available_count(range_demand)

        @output << line
      end
    end

    # == NEW
    #@quantities = {}
    #@dates.each do |d|
    #  @quantities[d[:header]] = OrderItem.orders.primary_companies.
    #    where('due_date BETWEEN ? AND ?', d[:start], d[:stop]).
    #    group(:product_id).sum(:quantity)
    #end
    #
    #results.all.each do |prod|
    #  line = [prod.facility_name, nil, prod.item_number, prod.description,
    #    prod.pallet_quantity, prod.current_inventory, prod.demand]
    #
    #  @dates.each do |d|
    #    line << @quantities[d[:header]][prod.id]
    #  end
    #
    #  @output << line
    #end
  end

end
