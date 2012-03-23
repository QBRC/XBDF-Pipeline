Pipeline::Application.routes.draw do
  resources :jobs do
    resources :runs
    match 'files' => 'files#index'
    match 'download' => 'jobs#download'
  end
  match 'jobs/:id/start' => 'jobs#start_job', :as => :start_job
  match 'jobs/:job_id/runs/:id/stop' => 'runs#stop', :as => :stop_run
  match 'jobs/:job_id/runs/:id/restart' => 'runs#restart', :as => :restart_run

  resources :commands do
    member do
      match 'download' => 'commands#download'
    end
  end
  # match 'commands/:id/download/:filename' => 'commands#download', :as => :download_command_xml
  
  # ActiveAdmin.routes(self)

  # devise_for :admin_users, ActiveAdmin::Devise.config

  match 'user/edit' => 'users#edit', :as => :edit_current_user

  match 'signup' => 'users#new', :as => :signup

  match 'logout' => 'sessions#destroy', :as => :logout

  match 'login' => 'sessions#new', :as => :login

  resources :sessions

  resources :users

  # match 'signup_for/:organization_alias' => 'students#new', :as => :signup_for
  # match 'organizations/:id/:filename.csv' => 'organizations#to_csv'

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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  root :to => "users#index"


end
