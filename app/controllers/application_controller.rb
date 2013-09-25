class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :create_search_params

  respond_to :csv, :html

  protected
    def create_search_params
      @search = params.delete_if {|k,v| %w(action controller format).include?(k)}
    end
end
