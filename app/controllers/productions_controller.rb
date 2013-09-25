class ProductionsController < ApplicationController

  respond_to :js, :only => [:limit_items, :item_information]

  def index
    respond_with(@productions =
      Production.where(inventory_entry: false).order("production_date DESC").paginate(page: params[:page]))
  end

  def show
    respond_with(@production = Production.find(params[:id]))
  end

  def new
    respond_with(@production = Production.new)
  end

  def edit
    respond_with(@production = Production.find(params[:id]))
  end

  def create
    respond_with(@production = Production.create(params[:production]), location: productions_path)
  end

  def update
    @production = Production.find(params[:id])
    @production.update_attributes(params[:production])
    respond_with(@production, location: productions_path)
  end

  # == AJAX REQUESTS
  def limit_items
    @products = Product.search(params).order('item_number').all
    respond_with(@products)
  end

  def item_information
    @product = Product.find(params[:product_id])
    @product.facility_id = params[:facility_id]
    respond_with(@product)
  end

end
