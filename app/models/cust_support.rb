class CustSupport < ActiveRecord::Base
  
  # == DATABASE CONNECTION
  self.establish_connection(:production #:cust_support_development)
  
end