class CallEntry < ActiveRecord::Base

  # == DATABASE CONNECTION
  self.establish_connection(:cust_support_development)

  set_table_name 'customer_support_log'

  CALLTYPE = ['Complaint', 'General Inquiry', 'Sales']

  PRODUCTGROUP = ['Sakrete', 'Bonsal American', 'ProSpec', 'Maximizer', 'Amerimix']

  CALLCATEGORY = ['Application', 'Color Loss', 'Defective Product', 'Debris', 'Insects',
    'Moisture Problems', 'MSDS Request', 'Other', 'Product Does Not Work', 'Product Question',
    'Safe for Pets and Children', 'Where to Purchase', 'Shortage', 'Overage', 'Wrong Product Shipped']

  LOGGEDBY = ['Brock Bowman', 'Mike Boenish','Andreas Moresi','Mike Brennan','Sal Suevo']

  # == SCOPES
  default_scope order('date DESC')

end