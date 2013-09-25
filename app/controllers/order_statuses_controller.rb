class OrderStatusesController < ApplicationController

  def show
  end

  def create
    @orders = Order.primary_companies.where(:status => %w(OR O)).
      where('due_date BETWEEN ? AND ?', params[:order_status][:start_date], params[:order_status][:end_date]).all

    respond_to do |format|
      format.csv do
        headers['Content-Type'] = "application/csv"
        headers['Content-Disposition'] = "attachment;filename=order_status.csv"
        render :text => @orders.to_comma(:status_report)
      end
    end

  end

end
