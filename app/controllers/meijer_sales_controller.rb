class MeijerSalesController < ApplicationController

  def show
   end

   def create
     params[:meijer_sale][:week] = params[:meijer_sale][:week].to_i == 0 ? false : true

     @meijer_sales = MeijerSalesReport.new(params[:meijer_sale])

     respond_to do |format|
      format.csv do
      headers['Content-Type'] = "application/csv"
      headers['Content-Disposition'] = "attachment;filename=meijer_sales.csv"
         render :text => @meijer_sales.to_csv
       end
     end
   end
end