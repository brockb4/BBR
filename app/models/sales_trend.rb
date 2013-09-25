class SalesTrend < ActiveRecord::Base
  
  # == DATABASE CONNECTION
  self.establish_connection(:pos_sales_development)
  
  # == CSV OUTPUT
  comma do
    day to_date: "Day"
    state "State"
    patch "Patch"
    store_num "Store Number"
    assortment "Assortment"
    item_num "Item Number"
    description "Description"
    yesterday_onhand "On Hand"
    yesterday_onorder "On Order"
    ytd_sales "YTD Sales"
    pwe_sales "LW Sales"
    wtd_sales "WTD Sales"
    ptwo_weeks "Prev 2wks Sales"
    pthree_weeks "Prev 3wks Sales"
    next_three_weeks_ly "Next 3wks LY"
    cwos_onhand "WOS on Hand"
    cwos_onorder "WOS on Order"    
  end

end
