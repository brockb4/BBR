class OrderInventory < ActiveRecord::Base
  # == CLASS METHODS

  def self.patch
    SalesTrend.select('DISTINCT patch').order(:patch).all.collect {|x| x.patch}
  end

  def self.state
    SalesTrend.select('DISTINCT state').order(:state).all.collect {|x| x.state}
  end

  def self.store_num
    SalesTrend.select('DISTINCT [store_num]').order(:store_num).all.collect {|x| x.store_num}
  end

  def self.assortment
    SalesTrend.select('DISTINCT assortment').order(:assortment).all.collect {|x| x.assortment}
  end

  def self.description
    SalesTrend.select('DISTINCT description').order(:description).all.collect {|x| x.description}
  end

  def self.item_num
    SalesTrend.select('DISTINCT item_num').order(:item_num).all.collect {|x| x.item_num}
  end


  ##Report Query
  #
  #def initialize(options = {})
  #  @options = options || {}
  #
  #
  #  table = SalesTrend.arel_table
  #
  #  if @options[:state]
  #    where_clause = where_clause.and(table[:state].in(@options[:state]))
  #  end
  #  if @options[:patch]
  #    where_clause = where_clause.and(table[:patch].in(@options[:patch]))
  #  end
  #  if @options[:store_num]
  #    where_clause = where_clause.and(table[:store_num].in(@options[:store_num]))
  #  end
  #  if @options[:assortment]
  #    where_clause = where_clause.and(table[:assortment].in(@options[:assortment]))
  #  end
  #  if @options[:item_num]
  #    where_clause = where_clause.and(table[:item_num].in(@options[:item_num]))
  #  end
  #  if @options[:description]
  #    where_clause = where_clause.and(table[:description].in(@options[:description]))
  #  end
  #
  #  @results = SalesTrend.connection.select_all("select 
  #  day,
  #  state,
  #  patch,
  #  store_num,
  #  assortment,
  #  item_num,
  #  description,
  #  yesterday_onhand,
  #  yesterday_onorder,
  #  ytd_sales,
  #  pwe_sales,
  #  wtd_sales,
  #  ptwo_weeks,
  #  pthree_weeks,
  #  next_three_weeks_ly,
  #  cwos_onhand,
  #  cwos_onorder 
  #  from sales_trends
  #  where#{where_clause.to_sql} and day = (select max(day) from sales_trends) order by state asc, patch asc, store_num asc, assortment asc, description asc")
  #
  #end
  #
  #def results
  #  @output = []
  #  @output << generate_headers
  #  process_results(@results)
  #  @output.collect {|x| x.to_csv}.join('')
  #end
  #
  #protected
  #
  #def generate_headers
  #  header =  ['Day','State','Patch', 'Store Number', 'Assortment', 'Item Number', 'Descripton']
  #  header += ['On Hand', 'On Order', 'YTD Sales', 'LW Sales', 'WTD Sales', 'Prev 2wks Sales']
  #  header += ['Prev 3wks Sales', 'Next 3wks LY', 'WOS on Hand','WOS on Order']
  #end
  #
  #def process_results(results)
  #  results.each do |res|
  #    line = [res["day"], res["state"], res["patch"], res["store_num"], res["assortment"], res["item_num"], res["description"], res["yesterday_onhand"], res["yesterday_onorder"], res["ytd_sales"], res["pwe_sales"], res["wtd_sales"], res["ptwo_weeks"], res["pthree_weeks"], res["next_three_weeks_ly"], res["cwos_onhand"], res["cwos_onorder"]]
  #
  #    @output << line
  #  end
  #end

end
