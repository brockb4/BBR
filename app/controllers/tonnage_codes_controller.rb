class TonnageCodesController < ApplicationController
  # GET /tonnage_codes
  # GET /tonnage_codes.xml
  def index
    @tonnage_codes = TonnageCode.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tonnage_codes }
    end
  end

  # GET /tonnage_codes/1
  # GET /tonnage_codes/1.xml
  def show
    @tonnage_code = TonnageCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tonnage_code }
    end
  end

  # GET /tonnage_codes/new
  # GET /tonnage_codes/new.xml
  def new
    @tonnage_code = TonnageCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tonnage_code }
    end
  end

  # GET /tonnage_codes/1/edit
  def edit
    @tonnage_code = TonnageCode.find(params[:id])
  end

  # POST /tonnage_codes
  # POST /tonnage_codes.xml
  def create
    @tonnage_code = TonnageCode.new(params[:tonnage_code])

    respond_to do |format|
      if @tonnage_code.save
        format.html { redirect_to(@tonnage_code, :notice => 'Tonnage code was successfully created.') }
        format.xml  { render :xml => @tonnage_code, :status => :created, :location => @tonnage_code }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tonnage_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tonnage_codes/1
  # PUT /tonnage_codes/1.xml
  def update
    @tonnage_code = TonnageCode.find(params[:id])

    respond_to do |format|
      if @tonnage_code.update_attributes(params[:tonnage_code])
        format.html { redirect_to(@tonnage_code, :notice => 'Tonnage code was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tonnage_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tonnage_codes/1
  # DELETE /tonnage_codes/1.xml
  def destroy
    @tonnage_code = TonnageCode.find(params[:id])
    @tonnage_code.destroy

    respond_to do |format|
      format.html { redirect_to(tonnage_codes_url) }
      format.xml  { head :ok }
    end
  end
end
