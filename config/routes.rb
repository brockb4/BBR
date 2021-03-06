BBR::Application.routes.draw do
  #get "bom/index"
  
  resources :clothings

  root      to: "dashboard#index"

  resource  :demands
  resource  :sales
  resource  :orders
  resource  :order_items
  resource  :order_status
  resource  :royalty_reports
  resource  :tonnage_report
  resource  :lowes_sales
  resource  :order_inventory
  resource  :sales_compare
  resource  :menards_price_reports
  resource  :customer_support_logs
  resource  :meijer_sales
  resource  :forecast_volume

  resources :forecast_updates
  resources :royalty_companies
  resources :tonnage_codes
  resources :price_reports
  resources :call_entries
  resources :forecast_reviews
  resources :master_forecasts

  resources :productions do
    collection do
      get :limit_items
      get :item_information
    end
  end
end
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'bom#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

