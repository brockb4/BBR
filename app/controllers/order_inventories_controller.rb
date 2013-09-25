class OrderInventoriesController < ApplicationController

  def show
    @search = SalesTrend.search(params[:search])
   end

   def create
    @day = SalesTrend.select(:day).order("day DESC").first
    @trends = SalesTrend.where(day: @day.day).search(params[:search]).all
    
    respond_to do |format|
      format.csv {render csv: @trends}
    end
     
    #@order_inventories = OrderInventory.new(params[:order_inventory])
    
    #respond_to do |format|
    # format.csv do
    # headers['Content-Type'] = "application/csv"
    # headers['Content-Disposition'] = "attachment;filename=order_inventory.csv"
    #    render :text => @order_inventories.results
    #  end
    #end
  end
end
