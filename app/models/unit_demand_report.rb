class UnitDemandReport < ArelReport

  base_table OrderItem

  project :order_items      => [:product_group, :product_type, :item_number],
          :forecast_updates => [:future_plant]

  order_by :item_number

  #optional_field :plant, :check => :plant, :not_blank => true
  #optional_field :business_line, :check => :include_bu

  join ForecastUpdate do |base, fu|
    join(fu, Arel::Nodes::OuterJoin).
      on(base[:item_number].eq(fu[:item_number]).
      and(base[:plant].eq(fu[:current_plant])).
      and(base[:business_line].eq(fu[:business_line])).and(fu[:customer].eq("").or(fu[:customer].eq(nil))))
  end

  before_query :ignore_items
  before_query :set_filtering

  before_query do
    add_aggregate(:last_year,        :sum, :quantity, :invoice_date, '2010-01-01', Date.today - 1.year)
    add_aggregate(:this_year,        :sum, :quantity, :invoice_date, '2011-01-01', Date.today)
    add_aggregate(:last_year_full,   :sum, :quantity, :invoice_date, '2010-01-01', '2010-12-31')

    # our total inv groupings
    add_raw_project(Arel.sql("SUM(forecast_updates.inv_last_year) AS inv_last_year"))
    add_raw_project(Arel.sql("SUM(forecast_updates.inv_this_year) AS inv_this_year"))

    if options[:monthly]
      add_period_field(:this_jan, '2011-01-01', '2011-01-31')
      add_period_field(:this_feb, '2011-02-01', '2011-02-28')
      add_period_field(:this_mar, '2011-03-01', '2011-03-31')
      add_period_field(:this_apr, '2011-04-01', '2011-04-30')
      add_period_field(:this_may, '2011-05-01', '2011-05-31')
      add_period_field(:this_jun, '2011-06-01', '2011-06-30')
      add_period_field(:this_jul, '2011-07-01', '2011-07-31')
      add_period_field(:this_aug, '2011-08-01', '2011-08-31')
      add_period_field(:this_sep, '2011-09-01', '2011-09-30')
      add_period_field(:this_oct, '2011-10-01', '2011-10-31')
      add_period_field(:this_nov, '2011-11-01', '2011-11-30')
      add_period_field(:this_dec, '2011-12-01', '2011-12-31')
    else
      #add_period_field(:last_rest_this_year, Date.today - 1.year, '2010-12-31')
      #add_period_field(:last_jan_apr,        '2010-01-01', '2010-04-30')
      #add_period_field(:last_may_first_half, '2010-05-01', '2010-05-15')
      #add_period_field(:last_may_last_half,  '2010-05-16', '2010-05-31')
      #add_period_field(:last_jun_jul,        '2010-06-01', '2010-07-31')
      #add_period_field(:last_aug_dec,        '2010-08-01', '2010-12-31')
      add_period_field(:this_rest_this_year, Date.today,   '2011-12-31')
      add_period_field(:this_jan_apr,        '2011-01-01', '2011-04-30')
      add_period_field(:this_may_first_half, '2011-05-01', '2011-05-15')
      add_period_field(:this_may_last_half,  '2011-05-16', '2011-05-31')
      add_period_field(:this_jun_jul,        '2011-06-01', '2011-07-31')
      add_period_field(:this_aug_dec,        '2011-08-01', '2011-12-31')
    end
  end

  # == PROTECTED METHODS
  protected

  def add_period_field(field_name, start, stop)
    forecast   = ForecastUpdate.arel_table
    case_field = case_statement(default_table[:invoice_date].in(start.to_date..stop.to_date), "order_items.quantity", 0)
    multiplier = case_statement(forecast[:in_program].eq(true),
      Arel.sql("(1 + (CAST(ISNULL(forecast_updates.pct_change, 0) as float) / 100))"), 0)
    add_raw_project(Arel.sql("SUM(#{case_field} * #{multiplier}) AS #{Arel.sql(field_name.to_s)}"), field_name.to_s, true)
  end

  def ignore_items
    add_where(:item_number, :does_not_match_all, %w(%90-200% %90-205% %90-202% %90-208%))
    add_where(:item_number, :not_eq_all,         %w(20001 90-215 90-203 miles fuel\ surcharge))
    add_where(:item_number, :not_eq_all,         %w(Iowa Illinois))
  end

  def set_filtering
    add_where(:business_line, :not_eq, 'Internal')
    add_where(:business_line, :in, options[:business_line]) unless options[:business_line].blank?
    add_where(:plant,         :in, options[:plant])         unless options[:plant].blank?
    add_where(:product_group, :eq, options[:product_group]) unless options[:product_group].blank?
    add_where(:product_type,  :eq, options[:product_type])  unless options[:product_type].blank?
    add_where(:state,         :eq, options[:state])         unless options[:state].blank?
  end

  def after_query(results)
    if options[:monthly]
      breakdowns =          %w(jan feb mar apr may jun jul aug sep oct nov dec).collect(&:to_sym)
      breakdowns_for_bags = breakdowns[0..4]
    else
      breakdowns =          %w(rest_this_year jan_apr may_first_half may_last_half jun_jul aug_dec).collect(&:to_sym)
      breakdowns_for_bags = breakdowns[0..3]
    end

    new_results = results.collect do |rec|
      res = {
        :plant                    => rec[:future_plant],
        :product_group            => rec[:product_group],
        :product_type             => rec[:product_type],
        :item_number              => "=\"#{rec[:item_number]}\"",
        :description              => OrderItem.where(:item_number => rec[:item_number]).first.description,
        :business_line            => rec[:business_line],
        :pallet_quantity          => Product.where(:item_number => rec[:item_number]).first.try(:pallet_quantity),
        :current_inventory        => inventory_count(rec),
        :bags_on_hand             => bagging_count(rec),
        :percentage_growth        => 0,
        :last_year_to_date        => rec[:last_year],
        :this_year_to_date        => rec[:this_year],
        :total_estimate_next_year => 0}

      prefix = "this" #rec[:this_year] > 0 ? "this" : "last"

      res.merge!(breakdowns.inject({}) do |hash, breakdown|
        hash[breakdown] = rec["#{prefix}_#{breakdown}"]
        hash
      end)

      total          = breakdowns.inject(0) {|token, breakdown| token + res[breakdown]}
      total_for_bags = breakdowns_for_bags.inject(0) {|token, breakdown| token + res[breakdown]} || 0

      bags_needed = (total_for_bags - res[:bags_on_hand] - res[:current_inventory]).ceil
      res[:bags_needed_through_may] = bags_needed < 0 ? 0 : bags_needed

      breakdowns.each {|bd| res[bd] = res[bd].nan? ? 0 : res[bd].ceil}

      res[:total_estimate_next_year] = breakdowns.inject(0) {|token, bd| token + res[bd]}

      res[:percentage_growth] =
        "%0.2f" % (((res[:total_estimate_next_year] - res[:this_year_to_date]) / res[:this_year_to_date]) * 100)

      inventory_difference = rec[:inv_last_year].to_i - rec[:inv_this_year].to_i
      if inventory_difference != 0
        new_total = 0
        breakdowns.each do |bd|
          percentage = 1.0 / res[:total_estimate_next_year] * res[bd]
          percentage = percentage.nan? ? 0 : percentage
          bd_diff = (percentage * inventory_difference).round
          res[bd] += bd_diff
          new_total += res[bd]
        end
        res[:total_estimate_next_year] = new_total
      end

      res = nil if rec[:this_year].to_i == 0
      res
    end

    new_results.compact!
    new_results
  end

  def inventory_count(data)
    ret = Product.where(:item_number => data[:item_number])
    ret = ret.where(:facility_name => data[:plant]) if data[:plant].present?
    ret.sum(:current_inventory)
  end

  def bagging_count(data)
    ret = Product.where(:item_number => data[:item_number])
    ret = ret.where(:facility_name => data[:plant]) if data[:plant].present?
    ret = ret.all

    ret.map {|p| [p.hand_bags, p.zip_bags, p.premier_bags]}.flatten.compact.sum
  end

end
