class MasterForecast < ArelReport

  table_object OrderItem.arel_table

  project  :plant, :item_number, :product_group, :product_type
  order_by :product_type, :item_number

  optional_field :business_line, :check => :include_bu
  optional_field :customer_name, :check => :include_customer

  before_query :ignore_items
  before_query :set_filtering
  before_query :set_aggregates

  DATA_OPTIONS = {"All" => 0, "Existing Only" => 1, "Spanking New Only" => 2}

  # == INSTANCE METHODS
  def to_csv
    headers = %w(current_plant future_plant business_line customer item_number item_name this_year_ytd_units
                last_year_ytd_units unit_growth last_year_full_units this_year_estimated_units estimated_pct_change
                this_year_inventory last_year_inventory in_program_next_year est_next_year_units)

    headers += %w(ly_sales ty_sales ly_full_sales) if @options[:include_sales]

    records = []

    output = headers.to_csv

    self.all.each do |rec|
      upd = fetch_update(rec)

      record = [
        rec[:plant],
        upd.future_plant,
        rec[:business_line],
        rec[:customer_name],
        rec[:item_number],
        rec[:description],
        rec[:ty_units],
        rec[:ly_units],
        unit_growth(rec),
        rec[:ly_full_year],
        year_growth(rec),
        upd.pct_change,
        upd.inv_this_year,
        upd.inv_last_year,
        (upd.in_program ? 'YES' : 'NO'),
        upd.est_new_qty]

      record += [rec.ly_sales, rec.ty_sales, rec.ly_full_sales] if @options[:include_sales]
      records << record
    end

    records.sort! {|x, y| y[14] <=> x[14]}

    output += records.collect(&:to_csv).join
  end

  def fetch_update(data)
    rec = ForecastUpdate.find_for(data)

    if data[:customer_name] && !rec
      rec = ForecastUpdate.find_for(data, false)
      rec = rec.clone if rec
    end

    rec ||= ForecastUpdate.new

    if !rec.id
      rec.in_program  = data[:ty_units] > 0
      rec.est_new_qty = year_growth(data)
      rec.pct_change  = 0
      rec.future_plant = data[:plant]
      rec.inv_this_year = nil
      rec.inv_last_year = nil
    end

    rec
  end

  def year_growth(data)
    ug = unit_growth(data)

    return data[:ty_units].ceil if [0, 100].include? ug

    (data[:ly_full_year] * (1 + (ug / 100.0))).ceil
  end

  def unit_growth(data)
    ty = data[:ty_units] || 0
    ly = data[:ly_units] || 0
    return 0   if ty == 0
    return 100 if ly == 0

    (((ty - ly) / ly) * 100).ceil
  end

  alias_method :all_without_unlive_data, :all
  def all
    res = []
    res += all_without_unlive_data if [0, 1].include?(options[:data_select].to_i)
    res += all_unlive_data if [0, 2].include?(options[:data_select].to_i)
    res
  end

  # == PROTECTED METHODS
  protected

  def all_unlive_data
    scope = ForecastUpdate.not_live
    scope = scope.where(:business_line => @options[:business_line]) if @options[:business_line].present?
    scope = scope.where(:customer      => @options[:customer_name]) if @options[:customer_name].present?
    scope = scope.where(:current_plant => @options[:plant])         if @options[:plant].present?

    scope.all.map do |fu|
      { :business_line => fu.business_line,
        :customer_name => fu.customer,
        :plant         => fu.current_plant,
        :future_plant  => fu.future_plant,
        :item_number   => fu.item_number,
        :product_group => "",
        :product_type  => "",
        :ty_units      => 0,
        :ly_units      => 0,
        :ly_full_year  => 0,
        :description   => fu.item_name}.with_indifferent_access
    end
  end

  def after_query(results)
    results.each do |rec|
      rec[:description] = OrderItem.where(:plant => rec[:plant], :item_number => rec[:item_number]).first.description
    end
  end

  def ignore_items
    add_where(:item_number, :does_not_match_all, %w(%90-200% %90-205% %90-202% %90-208%))
    add_where(:item_number, :not_eq_all,         %w(20001 90-215 90-203 miles fuel\ surcharge))
    add_where(:item_number, :not_eq_all,         %w(Illinois Iowa Indiana Xtra\ Stop))
  end

  def set_filtering
    add_where(:business_line, :eq, @options[:business_line]) unless @options[:business_line].blank?
    add_where(:plant,         :eq, @options[:plant])         unless @options[:plant].blank?
    add_where(:product_group, :eq, @options[:product_group]) unless @options[:product_group].blank?
    add_where(:product_type,  :eq, @options[:product_type])  unless @options[:product_type].blank?
    add_where(:state,         :eq, @options[:state])         unless @options[:state].blank?
    add_where(:customer_name, :eq, @options[:customer_name]) unless @options[:customer_name].blank?
  end

  def set_aggregates
    start = Date.parse('2011-01-01')
    stop  = Date.today

    add_aggregate(:ty_units,     :sum, :quantity, :invoice_date, start,          stop)
    add_aggregate(:ly_units,     :sum, :quantity, :invoice_date, start - 1.year, stop - 1.year)
    add_aggregate(:ly_full_year, :sum, :quantity, :invoice_date, start - 1.year, start - 1.day)

    return unless @options[:include_sales]

    add_aggregate(:ty_sales,      :sum, :item_subtotal, :invoice_date, start, stop)
    add_aggregate(:ly_sales,      :sum, :item_subtotal, :invoice_date, start - 1.year, stop - 1.year)
    add_aggregate(:ly_full_sales, :sum, :item_subtotal, :invoice_date, start - 1.year, start - 1.day)
  end

end
