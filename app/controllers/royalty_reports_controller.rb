class RoyaltyReportsController < ApplicationController

  def show ; end

  def create
    @report = RoyaltyReport.new(params[:royalty])

    respond_to do |format|
      format.csv do
        headers['Content-Type'] = "application/csv"
        headers['Content-Disposition'] = "attachment;filename=royalty_report.csv"
        render :text => @report.to_csv
      end
    end
  end

end
