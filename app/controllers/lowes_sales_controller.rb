class LowesSalesController < ApplicationController

  def show
   end

   def create
     @lowes_sales = LowesSale.new(params[:lowes_sale])

     respond_to do |format|
      format.csv do
      headers['Content-Type'] = "application/csv"
      headers['Content-Disposition'] = "attachment;filename=lowes_sales.csv"
         render :text => @lowes_sales.results
       end
     end
   end
end