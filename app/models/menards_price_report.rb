class MenardsPriceReport

  
  #Report Query

    def initialize(options = {})
      @options = options || {}


      table = OrderItem.arel_table
      
      puts "tbl: #{table.inspect}"
      puts "field: #{table[:order_date].inspect}"
      puts "opts: #{@options.inspect}"
      
      where_clause = table[:order_date].in(Date.parse(@options[:begin_date])..Date.parse(@options[:end_date]))

    
      @results = OrderItem.connection.select_all(sql = "select 
      customer_name,
      plant,
      invoice_number,
      po_number,
      order_date,
      due_date,
      state,
      city,
      item_number,
      menards_item,
      description,
      quantity,
      pallets,
      sum(pallet_weight*pallets) as weight,
      sent_price,
      our_price,
      sum(our_price-sent_price) as price_diff
      from
      ( 
       select 
       customer_name,
       plant,
       invoice_number,
       po_number,
       cast(order_date as datetime) as order_date,
       cast(due_date as datetime) as due_date,
       pallet_weight,
       order_items.state,
       order_items.city,
       item_number,
       menards_item,
       description,
       quantity,
       sum(quantity/nullif((pallet_qty),0)) as pallets,
       cast(sum(item_subtotal/(nullif((quantity),0)))as money) as sent_price,
       price as our_price
       from order_items
       left join menards_pricing on (order_items.item_number=menards_pricing.myob_item) and (order_items.state=menards_pricing.state)
       where status ='OR' and business_line ='Menards' and order_items.item_number not in('90-200')
       group by customer_name,plant,invoice_number,po_number,order_date,due_date,pallet_weight,order_items.state,order_items.city,item_number,menards_item,description,quantity,item_subtotal,menards_pricing.price
       ) as order_items
      where #{where_clause.to_sql}  group by customer_name,plant,invoice_number,po_number,order_date,due_date,state,city,item_number,menards_item,description,quantity,pallets,sent_price,our_price
        order by order_date asc,due_date asc") 

    end

    def results
      @output = []
      @output << generate_headers
      process_results(@results)
      @output.collect {|x| x.to_csv}.join('')
    end

    protected

      def generate_headers
      header =  ['Customer', 'Plant', 'Invoice #', 'PO Number', 'Order Date', 'Due Date']
      header += ['State', 'City', 'Item Number', 'Menards Number', 'Description', 'Quantity']
      header += ['Pallets', 'Weight', 'Sent Price', 'Our Price', 'Price Diff']
    end

    def process_results(results)
      results.each do |res|
        line = [res["customer_name"], res["plant"], res["invoice_number"], res["po_number"], res["order_date"], res["due_date"], res["state"], res["city"], res["item_number"], res["menards_item"], res["description"], res["quantity"], res["pallets"], res["weight"], res["sent_price"], res["our_price"], res["price_diff"]]

        @output << line
      end
    end
end
