class SalesComparesController < ApplicationController

  def show
    @sale_compare = SaleCompare.new

    respond_to do |format|
     format.csv do
     headers['Content-Type'] = "application/csv"
     headers['Content-Disposition'] = "attachment;filename=sales_compare.csv"
        render :text => @sale_compare.results
      end
    end
  end

end
