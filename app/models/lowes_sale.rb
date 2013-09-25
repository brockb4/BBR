class LowesSale
  
  # == CLASS METHODS
  def self.begin_date
    PosSale.select('DISTINCT [week]').order('[week] desc').all.collect {|x| x.week.to_date}
  end

  def self.end_date
    PosSale.select('DISTINCT [week]').order('[week] desc').all.collect {|x| x.week.to_date}
  end

  def self.patch
    PosSale.select('DISTINCT patch').order(:patch).all.collect {|x| x.patch}
  end

  def self.state
    PosSale.select('DISTINCT state').order(:state).all.collect {|x| x.state}
  end
  
  def self.store_num
    PosSale.select('DISTINCT [store_num]').order(:store_num).all.collect {|x| x.store_num}
  end
  
  def self.district
    Store.select('DISTINCT district').order(:district).all.collect {|x| x.district}
  end
  
  def self.region
    Store.select('DISTINCT region').order(:region).all.collect {|x| x.region}
  end
  
  def self.assortment
    PosSale.select('DISTINCT assortment').order(:assortment).all.collect {|x| x.assortment}
  end
  
  def self.description
    PosSale.select('DISTINCT description').order(:description).all.collect {|x| x.description}
  end
  
  def self.item_num
    PosSale.select('DISTINCT item_num').order(:item_num).all.collect {|x| x.item_num}
  end
  
  def self.rep
     Store.select('DISTINCT rep').order(:rep).all.collect {|x| x.rep}
   end
  

  

#Report Query

  def initialize(options = {})
    @options = options || {}
    
    @options[:week] =@options[:week].to_i==1?true:false
    
    table = PosSale.arel_table
    store_table = Store.arel_table
    where_clause = table[:week].in(Date.parse(@options[:begin_date])..Date.parse(@options[:end_date]))
    
    if @options[:state]
    	where_clause = where_clause.and(table[:state].in(@options[:state]))
    end
    if @options[:patch]
    	where_clause = where_clause.and(table[:patch].in(@options[:patch]))
    end
    if @options[:store_num]
    	where_clause = where_clause.and(table[:store_num].in(@options[:store_num]))
    end
    if @options[:district]
    	where_clause = where_clause.and(store_table[:district].in(@options[:district]))
    end
    if @options[:region]
    	where_clause = where_clause.and(table[:region].in(@options[:region]))
    end
    if @options[:assortment]
    	where_clause = where_clause.and(table[:assortment].in(@options[:assortment]))
    end
    if @options[:item_num]
    	where_clause = where_clause.and(table[:item_num].in(@options[:item_num]))
    end
    if @options[:description]
    	where_clause = where_clause.and(table[:description].in(@options[:description]))
    end
    if @options[:rep]
    	where_clause = where_clause.and(table[:rep].in(@options[:rep]))
    end
    
    sql = "select
            state,
            patch,
            district,
            region,
            store_num,
            assortment,
            item_num,
            description,
            ty_sales_units,
            ly_sales_units,
            sum((ty_sales_units-ly_sales_units)/nullif((ly_sales_units),0)) as unit_comp,
            ty_sales,ly_sales,
            sum((ty_sales - ly_sales) / nullif((ly_sales), 0)) As sales_comp
          from 
      		(
            select
            pos_sales.state,
            pos_sales.patch,
            district,region,
            pos_sales.store_num,
            assortment,
            item_num,
            description,
            sum(ty_sales_units) as ty_sales_units,
            sum(ly_sales_units) as ly_sales_units,
            sum(ty_sales) as ty_sales,
            sum(ly_sales) as ly_sales 
          from
            pos_sales
            inner join store on (pos_sales.store_num=store.store_num)
            where #{where_clause.to_sql} 
            group by pos_sales.state,pos_sales.patch,district,region,pos_sales.store_num,assortment,item_num,description
      		) as r
            group by state,patch,district,region,store_num,assortment,item_num,description,ty_sales_units,ly_sales_units,ty_sales,ly_sales
            order by state asc, patch asc, store_num asc, assortment asc, item_num asc,description asc"
    
    if @options[:week]
      sql = "select
            state,
            patch,
            district,
            region,
            week,
            store_num,
            assortment,
            item_num,
            description,
            ty_sales_units,
            ly_sales_units,
            sum((ty_sales_units-ly_sales_units)/nullif((ly_sales_units),0)) as unit_comp,
            ty_sales,ly_sales,
            sum((ty_sales - ly_sales) / nullif((ly_sales), 0)) As sales_comp
          from 
      		(
            select
            pos_sales.state,
            pos_sales.patch,
            district,region,
            pos_sales.week,
            pos_sales.store_num,
            assortment,
            item_num,
            description,
            sum(ty_sales_units) as ty_sales_units,
            sum(ly_sales_units) as ly_sales_units,
            sum(ty_sales) as ty_sales,
            sum(ly_sales) as ly_sales 
          from
            pos_sales
            inner join store on (pos_sales.store_num=store.store_num)
            where #{where_clause.to_sql} 
            group by pos_sales.state,pos_sales.patch,district,region,week,pos_sales.store_num,assortment,item_num,description
      		) as r
            group by state,patch,district,region,store_num,week,assortment,item_num,description,ty_sales_units,ly_sales_units,ty_sales,ly_sales
            order by week asc, state asc, patch asc, store_num asc, assortment asc, item_num asc,description asc"
    end   
    
    @results = PosSale.connection.select_all(sql)     
  end

  def results
    @output = []
    @output << generate_headers
    process_results(@results)
    @output.collect {|x| x.to_csv}.join('')
  end

  protected

    def generate_headers
    header =  ['State', 'Patch', 'Store Number', 'Assortment', 'Item Number', 'Descripton']
    header += ['TY Sales Units', 'LY Sales Units', 'Unit Comp', 'TY Sales $', 'LY Sales $', 'Sales Comp']
    header += ['Week'] if @options[:week]
    header
  end

  def process_results(results)
    results.each do |res|
      line = [res["state"], res["patch"], res["store_num"], res["assortment"], res["item_num"], res["description"], res["ty_sales_units"], res["ly_sales_units"], res["unit_comp"], res["ty_sales"], res["ly_sales"], res["sales_comp"]]
      line << res["week"].to_date if @options[:week]
      @output << line
    end
  end

end
