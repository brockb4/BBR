class TonnageReport < ActiveRecord::Base

  # == CLASS METHODS
  def self.brands
    TonnageCode.select('DISTINCT brand').all.collect(&:brand)
  end

  def initialize(options = {})
    @start   = Date.parse(options[:start_date])
    @stop    = Date.parse(options[:end_date])
    @options = options
    @options[:brand] = nil if @options[:brand].blank?

    @postal  = PostalCode.arel_table
    @codes   = TonnageCode.arel_table
    @items   = OrderItem.arel_table
  end

  def all
    @results = generate.to_a

    @results.collect do |rec|
      ret = rec.data

      if !ret[:county_fips]
        postal = PostalCode.where(city_name: rec.city, state_abbr: rec.state).first
        if postal
          ret["county_name"] = postal.county_name
          ret["county_fips"] = postal.county_fips[-3..-1]
        end
      end

      # now we're just going OUT OF OUR WAY to find a fips!!!
      if !ret[:county_fips]
        itm = OrderItem.where(city: rec.city, state: rec.state).where('zip_code IS NOT NULL').first
        postal = PostalCode.where(zip_code: itm.zip_code[0..4]).first if itm
        if postal
          ret["county_name"] = postal.county_name
          ret["county_fips"] = postal.county_fips[-3..-1]
        end
      end

      ret
    end
  end

  def handle_sta_green(rec)
    invoices = %w(MO).include?(rec["state"]) ?
      invoice_numbers(rec["state"], rec["zip_code"], rec["item_number"]).join(", ") : ""

    ret  = [rec["state"], rec["item_number"], rec["description"], rec["weight"], "", "", "", ""]
    ret += [rec["units_shipped"], rec["tons_shipped"], rec["zip_code"], "", invoices]
    puts ret.inspect
    ret
  end

  def to_csv
    records = all
    return unless records[0]
    headers = records[0].keys
    results = ["Country Stone", "Tonnage Report"].to_csv +
      ["From:", @start.to_s].to_csv +
      ["To: ", @stop.to_s].to_csv +
      [].to_csv

    if @options[:brand] == "Sta-Green"
      results += ["State", "Item #", *%w(Description Weight N P K),
        "Tonnage Code", *%w(Units Shipped Zipcode Customer), "Invoice"].to_csv

      records.each do |rec|
        results += handle_sta_green(rec).to_csv
      end
    else
      results += headers.to_csv

      records.each do |rec|
        line = headers.collect {|h| rec[h]}
        results += line.to_csv
      end
    end

    results
  end

  def generate
    @query = base_query
    @query = add_optionals(@query)
    @query = @query.where(@items[:invoice_date].in(@start..@stop))
    @query
  end

  def add_optionals(query)
    query = query.where(@codes[:brand].eq(@options[:brand]))
  end

  def base_query
    @base_query ||= @codes.
      project(@codes[:item_number]).
      project(@codes[:description]).
      project(@codes[:weight]).
      project(@codes[:code]).
      project(@items[:city]).
      project(@items[:state]).
      project(@items[:zip_code]).
      project(@postal[:county_name]).
      project(Arel.sql("SUBSTRING(postal_codes.county_fips, 3, 3) AS county_fips")).
      project(Arel.sql("SUM(order_items.quantity) AS units_shipped")).
      project(Arel.sql("SUM(order_items.quantity * tonnage_codes.weight)/2000 AS tons_shipped")).
      group(@codes[:item_number]).
      group(@codes[:description]).
      group(@codes[:weight]).
      group(@codes[:code]).
      group(@items[:city]).
      group(@items[:state]).
      group(@items[:zip_code]).
      group(@postal[:county_name]).
      group(Arel.sql("SUBSTRING(postal_codes.county_fips, 3, 3)")).
      join(@items).on(@codes[:item_number].eq(@items[:item_number])).
      join(@postal, Arel::Nodes::OuterJoin).on(@items[:city].eq(@postal[:city_name]).
        and(@items[:state].eq(@postal[:state_abbr])).
        and(@postal[:zip_code].eq(Arel.sql("SUBSTRING(order_items.zip_code, 1, 5)")))).
      where(@items[:company_name].
        in(['Country Stone', 'Menards&Blains', 'Infinity Fertilizers'])).
      where(@items[:status].in(['O', 'C'])).
      where(@items[:business_line].not_eq("Internal"))
  end

  def invoice_numbers(state, zipcode, item_number)
    query = @items.
      project(@items[:invoice_number]).
      where(@items[:state].eq(state)).
      where(@items[:zip_code].eq(zipcode)).
      where(@items[:item_number].eq(item_number))

    query.to_a.collect(&:invoice_number).uniq.sort
  end

end
