class MeijerPosSale < ActiveRecord::Base

  # == DATABASE CONNECTION
  self.establish_connection(:pos_sales_development)

  class << self
    def begin_date
      select('DISTINCT [week]').order('[week] desc').all.collect {|x| x.week.to_date}
    end

    def end_date
      select('DISTINCT [week]').order('[week] desc').all.collect {|x| x.week.to_date}
    end

    def store_num
      select('DISTINCT [store_num]').order(:store_num).all.collect {|x| x.store_num}
    end

    def description
      select('DISTINCT description').order(:description).all.collect {|x| x.description}
    end

    def items
      select('DISTINCT item_number, description').order(:description).all.collect do |x|
        ["#{x.description} - #{x.item_number}", x.item_number]
      end
    end


  end

end
