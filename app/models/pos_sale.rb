class PosSale < ActiveRecord::Base
  
  # == DATABASE CONNECTION
  self.establish_connection(:pos_sales_development)
  
end
