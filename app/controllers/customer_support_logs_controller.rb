class CustomerSupportLogsController < ApplicationController

  def show
   end

   def create
     @customer_support_logs = CustomerSupportLog.new(params[:customer_support_log])

     respond_to do |format|
      format.csv do
      headers['Content-Type'] = "application/csv"
      headers['Content-Disposition'] = "attachment;filename=call_log_report.csv"
         render :text => @customer_support_logs.results
       end
     end
   end
end
