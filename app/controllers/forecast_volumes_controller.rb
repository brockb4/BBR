class ForecastVolumesController < ApplicationController

  def show
  end

  def create
    params[:report][:include_bu] = params[:report][:include_bu].to_i == 1 ? true : false
    params[:report][:monthly]    = params[:report][:monthly].to_i    == 1 ? true : false
    params[:report][:include_bu] = true if params[:report][:business_line].present?
    @report = UnitDemandReport.new(params[:report])

    respond_to do |format|
      format.csv do
        headers['Content-Type'] = "application/csv"
        headers['Content-Disposition'] = "attachment;filename=unit_demand_report.csv"
        render :text => @report.to_csv
      end
    end
  end

end
