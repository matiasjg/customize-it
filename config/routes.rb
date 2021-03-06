Rails.application.routes.draw do


  get 'admin', to: 'admin#index'
  get 'admin/login'
  post 'admin/login', to: 'admin#login_check'
  get 'admin/logout'
  get 'admin/shops'
  get 'admin/shops/:id', to: 'admin#edit_store'
  patch 'admin/shops/:id', to: 'admin#update_store'
  get 'admin/delete_store'

  scope '/admin' do
    resources :users
    resources :shops, :only => [:index, :show]
  end

  root :to => 'home#index'

  get 'steps/not-allowed', to: 'steps#not_allowed'

  resources :steps

  post 'webhooks/orders/create', to: 'webhooks#order_create'
  delete 'webhook/:id', to: 'webhooks#destroy'
  get 'webhooks', to: 'webhooks#index'
  post 'webhooks', to: 'webhooks#create'

  get 'proxy', to: 'proxy#index'
  get 'proxy/show', to: 'proxy#show'
  get 'proxy/step/:step_id', to: 'proxy#get_setp_info'
  get 'proxy/:step_url/', to: 'proxy#index'
  get 'proxy/:step_url/:handle/', to: 'proxy#index'

  controller :sessions do
    get 'login' => :new, :as => :login
    post 'login' => :create, :as => :authenticate
    get 'auth/shopify/callback' => :callback
    get 'logout' => :destroy, :as => :logout
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
