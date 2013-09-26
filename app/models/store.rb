class Store < ActiveRecord::Base
  
  # == DATABASE CONNECTION
  self.establish_connection(:production) #:pos_sales_development)
  set_table_name 'store'
  set_primary_key 'store_num'
  
end