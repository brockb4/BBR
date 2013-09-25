class ForecastUpdatesController < ApplicationController
  # GET /forecast_updates
  # GET /forecast_updates.xml
  def index
    @forecast_updates = ForecastUpdate.not_live.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forecast_updates }
    end
  end

  # GET /forecast_updates/1
  # GET /forecast_updates/1.xml
  def show
    @forecast_update = ForecastUpdate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @forecast_update }
    end
  end

  # GET /forecast_updates/new
  # GET /forecast_updates/new.xml
  def new
    @forecast_update = ForecastUpdate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @forecast_update }
    end
  end

  # GET /forecast_updates/1/edit
  def edit
    @forecast_update = ForecastUpdate.find(params[:id])
  end

  # POST /forecast_updates
  # POST /forecast_updates.xml
  def create
    @forecast_update = ForecastUpdate.new(params[:forecast_update].merge(:unlive => true, :in_program => true))

    respond_to do |format|
      if @forecast_update.save
        format.html { redirect_to(forecast_updates_path, :notice => 'Forecast update was successfully created.') }
        format.xml  { render :xml => @forecast_update, :status => :created, :location => @forecast_update }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @forecast_update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forecast_updates/1
  # PUT /forecast_updates/1.xml
  def update
    @forecast_update = ForecastUpdate.find(params[:id])

    respond_to do |format|
      if @forecast_update.update_attributes(params[:forecast_update])
        format.html { redirect_to(forecast_updates_path, :notice => 'Forecast update was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @forecast_update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forecast_updates/1
  # DELETE /forecast_updates/1.xml
  def destroy
    @forecast_update = ForecastUpdate.find(params[:id])
    @forecast_update.destroy

    respond_to do |format|
      format.html { redirect_to(forecast_updates_url) }
      format.xml  { head :ok }
    end
  end
end
