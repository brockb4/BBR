class CallEntriesController < ApplicationController

  def index
    respond_with(@call_entries = CallEntry.paginate(:page => params[:page]))
  end

  def show
    respond_with(@call_entry = CallEntry.find(params[:id]))
  end

  def new
    respond_with(@call_entry = CallEntry.new)
  end

  def edit
    respond_with(@call_entry = CallEntry.find(params[:id]))
  end

  def create
    respond_with(@call_entry = CallEntry.create(params[:call_entry]), location: call_entries_path)
  end
  
  def update
    @call_entry = CallEntry.find(params[:id])
    respond_with(@call_entry.update_attributes(params[:call_entry]), :location => call_entries_path)
  end

end
