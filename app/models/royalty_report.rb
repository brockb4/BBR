class RoyaltyReport

  def initialize(options = {})
    @options    = options
    @start_date = Date.parse(options[:start_date])
    @stop_date  = Date.parse(options[:stop_date])
    @company    = RoyaltyCompany.arel_table
    @join       = RoyaltyItem.arel_table
    @items      = OrderItem.arel_table
  end

  def all
    base_query.to_a
  end

  def to_csv
    company = RoyaltyCompany.find(@options[:company_id])
    records = all
    total   = 0.0
    less_freight = 0.0
    results = [
      ["Country Stone"],
      ["Royalty Calculation", company.name],
      ["Date Range", @start_date.to_s, @stop_date.to_s],
      ["",""], records[0].data.keys].collect {|line| line.to_csv}.join()

    records.each do |rec|
      total += rec.total_sales
      results += rec.data.values.to_csv
    end
    results += ["", ""].to_csv

    results += ["", "Grand Total", total.round(2)].to_csv
    results += ["", ""].to_csv

    if company.less_freight
      less_freight = (total / 6800) * 450
      total -= less_freight

      results += ["", "Less Freight", less_freight.round(2)].to_csv
      results += ["", ""].to_csv
    end

    results += ["", "Royalty Basis", total.round(2)].to_csv
    results += ["", ""].to_csv

    results += ["", "Royalty", company.royalty].to_csv
    results += ["", ""].to_csv

    results += ["", "Net Due", (total * (company.royalty / 100)).round(2)].to_csv
  end

  # == PROTECTED METHODS
  protected

  def base_query
    @base_query ||= @company.
      join(@join).on(@company[:id].eq(@join[:royalty_company_id])).
      join(@items, Arel::Nodes::OuterJoin).on(@join[:item_number].eq(@items[:item_number])).
      project(@join[:item_number]).
      project(@join[:description]).
      project(@items[:item_subtotal].sum.as('total_sales')).
      where(@company[:id].eq(@options[:company_id])).
      where(@items[:company_name].in(['Country Stone', 'Colorado Lava', 'Menards&Blains', 'Green Thumb of Georgia', 'Infinity Fertilizers'])).
      where(@items[:status].in(['O', 'C'])).
      where(@items[:business_line].not_eq("Internal")).
      where(@items[:invoice_date].in(@start_date..@stop_date)).
      group(@join[:item_number]).
      group(@join[:description])
  end

end
