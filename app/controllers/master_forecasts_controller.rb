class MasterForecastsController < ApplicationController

  def index
    @search = params[:master_forecast]

    if @search
      @search[:include_bu]       = @search[:include_bu].to_i == 1
      @search[:include_customer] = @search[:include_customer].to_i == 1
      @search[:include_sales]    = @search[:include_sales].to_i == 1

      @search[:include_bu]       = true unless @search[:business_line].blank?
      @search[:include_customer] = true unless @search[:customer_name].blank?
    end

    @records = []

    @forecast = MasterForecast.new(@search)

    respond_to do |format|
      format.html do
        if @search && @search.length > 0
          @records = @forecast.all
        end
        @search ||= {:include_bu => true}
      end

      format.csv do
        headers['Content-Type'] = "application/csv"
        headers['Content-Disposition'] = "attachment;filename=master_forecast.csv"
        render :text => @forecast.to_csv
      end
    end
  end

  def create
    params[:updates].each do |key, line|
      id = line.delete :id

      next if line.values.compact.length == 0

      record = id ? ForecastUpdate.find(id) : ForecastUpdate.create(line)

      record.update_attributes(line)
    end

    redirect_to :back
  end
end