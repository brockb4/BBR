class MenardsPriceReportsController < ApplicationController
  
  def show
   end
   
   def create
     @menards_price_reports = MenardsPriceReport.new(params[:menards_price_reports])

     respond_to do |format|
      format.csv do
      headers['Content-Type'] = "application/csv"
      headers['Content-Disposition'] = "attachment;filename=menards_price_report.csv"
         render :text => @menards_price_reports.results
       end
     end
   end
end



