class RoyaltyCompaniesController < ApplicationController
  # GET /royalty_companies
  # GET /royalty_companies.xml
  def index
    @royalty_companies = RoyaltyCompany.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @royalty_companies }
    end
  end

  # GET /royalty_companies/1
  # GET /royalty_companies/1.xml
  def show
    @royalty_company = RoyaltyCompany.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @royalty_company }
    end
  end

  # GET /royalty_companies/new
  # GET /royalty_companies/new.xml
  def new
    @royalty_company = RoyaltyCompany.new
    @royalty_company.royalty_items.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @royalty_company }
    end
  end

  # GET /royalty_companies/1/edit
  def edit
    @royalty_company = RoyaltyCompany.find(params[:id])
    @royalty_company.royalty_items.build
  end

  # POST /royalty_companies
  # POST /royalty_companies.xml
  def create
    @royalty_company = RoyaltyCompany.new(params[:royalty_company])

    respond_to do |format|
      if @royalty_company.save
        format.html { redirect_to(royalty_companies_path, :notice => 'Royalty company was successfully created.') }
        format.xml  { render :xml => @royalty_company, :status => :created, :location => @royalty_company }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @royalty_company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /royalty_companies/1
  # PUT /royalty_companies/1.xml
  def update
    @royalty_company = RoyaltyCompany.find(params[:id])

    respond_to do |format|
      if @royalty_company.update_attributes(params[:royalty_company])
        format.html { redirect_to(royalty_companies_path, :notice => 'Royalty company was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @royalty_company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /royalty_companies/1
  # DELETE /royalty_companies/1.xml
  def destroy
    @royalty_company = RoyaltyCompany.find(params[:id])
    @royalty_company.destroy

    respond_to do |format|
      format.html { redirect_to(royalty_companies_url) }
      format.xml  { head :ok }
    end
  end
end
