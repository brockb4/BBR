class CustSupport < ActiveRecord::Base
  
  # == DATABASE CONNECTION
  self.establish_connection(:cust_support_development)
  
end