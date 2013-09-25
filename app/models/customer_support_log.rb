class CustomerSupportLog < ActiveRecord::Base
    
    # == DATABASE CONNECTION
    self.establish_connection(:production) #:cust_support_development)
    
    set_table_name 'customer_support_log'
   
    def self.begin_date
      self.select('DISTINCT [date]').order('[date] desc').all.collect {|x| x.date.to_date}
    end

    def self.end_date
      self.select('DISTINCT [date]').order('[date] desc').all.collect {|x| x.date.to_date}
    end

    def self.logged_by
      self.select('DISTINCT logged_by').order(:logged_by).all.collect {|x| x.logged_by}
    end

    def self.call_type
      self.select('DISTINCT call_type').order(:call_type).all.collect {|x| x.call_type}
    end

    def self.call_category
      self.select('DISTINCT call_category').order(:call_category).all.collect {|x| x.call_category}
    end

    def self.product_group
      self.select('DISTINCT product_group').order(:product_group).all.collect {|x| x.product_group}
    end

    def self.product
      self.select('DISTINCT product').order(:product).all.collect {|x| x.product}
    end

    def self.city
      self.select('DISTINCT city').order(:city).all.collect {|x| x.city}
    end
    
    def self.state
      self.select('DISTINCT state').order(:state).all.collect {|x| x.state}
    end


  #Report Query

    def initialize(options = {})
      @options = options || {}

      table = CustomerSupportLog.arel_table
      where_clause = table[:date].in(Date.parse(@options[:begin_date])..Date.parse(@options[:end_date]))
      
      @options.keys.each do |field|
        next if [:begin_date, :end_date].include? field.to_sym
        where_clause = where_clause.and(table[field].in(@options[field]))
      end

      @results = self.connection.select_all(sql = "select 
      date,
      logged_by,
      call_type,
      call_category,
      product_group,
      product,
      customer_name,
      address,
      city,
      state,
      zip,
      phone_number,
      lot_code,
      customer_comments,
      our_response,reimburse,
      plant,
      store 
      from customer_support_log
      where #{where_clause.to_sql} 
      order by product_group asc,date,product asc") 

    end

    def results
      @output = []
      @output << generate_headers
      process_results(@results)
      @output.collect {|x| x.to_csv}.join('')
    end

    protected

      def generate_headers
      header =  ['Date', 'Logged By', 'Call Type', 'Call Category', 'Product Group', 'Product']
      header += ['Customer Name', 'Address', 'City', 'State', 'Zip', 'Phone Number']
      header += ['Lot Code', 'Customer Comments', 'Our Responce', 'Reimburse', 'Plant', 'Store']
    end

    def process_results(results)
      results.each do |res|
        line = [res["date"], res["logged_by"], res["call_type"], res["call_category"], res["product_group"], res["product"], res["customer_name"], res["address"], res["city"], res["state"], res["zip"], res["phone_number"], res["lot_code"], res["customer_comments"], res["our_response"], res["reimburse"], res["plant"], res["store"]]

        @output << line
      end
    end

end
