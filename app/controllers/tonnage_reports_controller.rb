class TonnageReportsController < ApplicationController

  def show ; end

  def create
    @report = TonnageReport.new(params[:tonnage])

    respond_to do |format|
      format.csv do
        headers['Content-Type'] = "application/csv"
        headers['Content-Disposition'] = "attachment;filename=tonnage_report.csv"

        render :text => (@report.to_csv || ["No Records Found"].to_csv)
      end
    end
  end

end
