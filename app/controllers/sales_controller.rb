class SalesController < ApplicationController

  def show
  end

  def create
    @sales = SalesReport.new(params[:sales])

    respond_to do |format|
      format.csv do
        headers['Content-Type'] = "application/csv"
        headers['Content-Disposition'] = "attachment;filename=sales_report.csv"
        render :text => @sales.to_csv
      end
    end
  end

end
