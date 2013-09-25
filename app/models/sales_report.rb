class SalesReport

  # == CONSTANTS
  GRANULARITY = ['Daily', 'Weekly', 'Monthly', 'Total Range']

  attr_accessor :facility_ids, :granularity

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

  # == INITIALIZER
  def initialize(options = {})
    @options      = options
    @products     = Product.arel_table
    @order_items  = OrderItem.arel_table
    @granularity  = options[:granularity] || 'Total Range'

    @optional_fields = {
      facility_name: @products[:facility_name],
      business_line: @order_items[:business_line],
      customer:      @order_items[:customer_name],
      group:         @products[:group],
      kind:          @products[:kind],
      status:        @order_items[:status],
      city:          @order_items[:city],
      state:         @order_items[:state]
    }

    if options[:begin_date] && options[:end_date]
      add_date_range(options[:begin_date], options[:end_date])
    end
  end

  def add_date_range(start, stop)
    @date_ranges ||= []

    start = start.is_a?(String) ? Date.parse(start) : start
    stop  = stop.is_a?(String)  ? Date.parse(stop)  : stop

    case @options[:granularity]
    when 'Weekly'
      start = start.monday
      stop = stop.sunday
    when 'Monthly'
      start -= (start.day - 1)
      stop = (stop >> 1) - stop.day
    end

    @date_ranges << {start: start, stop: stop}
  end

  def all
    @query = base_query
    add_optional_fields
    add_granularity_field
    add_aggregate_fields
    @query.to_a
  end

  def to_csv
    records = self.all
    return nil if records.empty?

    headers = records[0].data.keys

    results = (headers + ['Unit Growth', 'Sales Growth']).to_csv
    records.each do |rec|
      next unless rec.this_year_quantity || rec.last_year_quantity || rec.this_year_sales || rec.last_year_sales
      line = headers.collect {|h| rec.data[h]}
      line << calculate_growth(rec.this_year_quantity, rec.last_year_quantity)
      line << calculate_growth(rec.this_year_sales, rec.last_year_sales)

      line[3] = quote_value(line[3])

      results += line.to_csv
    end

    results
  end


  # == PROTECTED METHODS
  protected

  def date_format(field)
    ret = case @granularity
    when 'Daily'
      'CONVERT(varchar(10), %, 111)'
    when 'Weekly'
      "CONVERT(varchar(4), YEAR(%)) + '-' + RIGHT(REPLICATE('0',2) + CONVERT(varchar(2), DATEPART(wk, %)), 2)"
    when 'Monthly'
      'CONVERT(varchar(7), %, 111)'
    when 'Total Range'
      'NULL'
    end

    ret.gsub('%', field)
  end

  def base_query
    @base_query ||= @products.
      project(@order_items[:company_name]).
      project(@order_items[:status]).
      project(@products[:facility_name]).
      project(@products[:item_number]).
      project(@products[:description]).
      project(@products[:group].as(:category)).
      project(@products[:kind].as(:type)).
      project(@products[:pallet_quantity]).
      group(@order_items[:company_name]).
      group(@order_items[:status]).
      group(@products[:facility_name]).
      group(@products[:item_number]).
      group(@products[:description]).
      group(@products[:group]).
      group(@products[:kind]).
      group(@products[:pallet_quantity]).
      join(@order_items).on(@products[:id].eq(@order_items[:product_id])).
      where(@order_items[:company_name].
        in(['Country Stone', 'Colorado Lava', 'Menards&Blains', 'Green Thumb of Georgia', 'Infinity Fertilizers'])).
      where(@order_items[:status].in(['O', 'OR', 'C']))
  end

  def add_optional_fields
    @optional_fields.each do |key, field|
      opts = @options[key]
      opts = {"0" => false, "1" => true}[opts] if ["0", "1"].include? opts

      case opts
      when TrueClass
        @query = @query.project(field).group(field)
      when Array
        @query = @query.project(field).group(field).where(field.in(opts))
      when String
        @query = @query.project(field).group(field).where(field.eq(opts))
      end
    end
  end

  def add_granularity_field
    if @granularity == 'Total Range'
      @query = @query.project(Arel.sql("NULL as 'Total Range'"))
      return
    end

    this_year = case_when_clause(date_format('invoice_date'))
    last_year = case_when_clause(date_format('dateadd(yy, 1, invoice_date)'), true)

    clause = "CASE" + this_year + last_year + "END"
    @query = @query.
      project(Arel.sql(clause + " AS #{@granularity}")).
      group(Arel.sql(clause))
  end

  def add_aggregate_fields
    @query = @query.
      project(Arel.sql("SUM(" + case_clause(:quantity, 0) + ") AS this_year_quantity")).
      project(Arel.sql("SUM(" + case_clause(:quantity, 0, true) + ") AS last_year_quantity")).
      project(Arel.sql("SUM(" + case_clause(:item_subtotal, 0) + ") AS this_year_sales")).
      project(Arel.sql("SUM(" + case_clause(:item_subtotal, 0, true) + ") AS last_year_sales"))

    clause = nil
    @date_ranges.each do |dr|
      clause = append_date_where_clause(clause, dr[:start], dr[:stop])
      clause = append_date_where_clause(clause, dr[:start] - 1.year, dr[:stop] - 1.year)
    end

    @query = @query.where(clause)
  end

  def case_clause(success, failure, last_year = false)
    success_clause = case_when_clause(success, last_year)
    Arel.sql("CASE #{success_clause} ELSE #{failure} END")
  end

  def case_when_clause(success, last_year = false)
    where_clause = nil
    @date_ranges.each do |dr|
      start = last_year ? dr[:start] - 1.year : dr[:start]
      stop  = last_year ? dr[:stop]  - 1.year : dr[:stop]
      where_clause = append_date_where_clause(where_clause, start, stop)
    end
    Arel.sql(" WHEN " + where_clause.to_sql + " THEN #{success} ")
  end

  def append_date_where_clause(clause, start_date, end_date)
    append = @order_items[:invoice_date].in(start_date..end_date)
    clause ? clause.or(append) : append
  end

  def calculate_growth(current, historic)
    current  ||= 0.0
    historic ||= 0.0

    return 100 if historic == 0
    (current - historic) / historic
  end

  def quote_value(val)
    "=\"#{val}\""
  end
end
