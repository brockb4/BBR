class OrdersController < ApplicationController

  def show
    respond_to do |format|
      format.csv {render csv: Order.last_quarter.orders.primary_companies.search(@search).all}
    end
  end

end
