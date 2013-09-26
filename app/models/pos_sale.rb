class PosSale < ActiveRecord::Base
  
  # == DATABASE CONNECTION
  self.establish_connection(:production) #:pos_sales_development)
  
end
