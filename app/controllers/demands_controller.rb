class DemandsController < ApplicationController

  def show
  end

  def create
    @demand = Demand.new(params[:demand])

    respond_to do |format|
      format.csv do
        headers['Content-Type'] = "application/csv"
        headers['Content-Disposition'] = "attachment;filename=demand_report.csv"
        render :text => @demand.results
      end
    end
  end

end
