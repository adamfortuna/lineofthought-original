Snaps::Application.routes.draw do
  match '/' => 'home#index', :as => 'root'

  resources :tools do
    collection do 
      get :autocomplete
    end
    member do
      get :articles
    end
    resources :sites, :controller => "tool_sites", :only => [:index, :new, :create]
  end

  resources :sites do
    collection do 
      get :autocomplete
    end
    member do
      get :articles
    end
    resource :tools, :controller => "sites_tools", :only => [:index, :edit, :create, :destroy] do
      collection do 
        get :autocomplete
      end
    end
  end
  
  resources :articles, :only => [:new, :create, :index, :show]


  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :only => [:new, :create, :edit, :update],
    :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
    
  # match '/logout' => 'sessions#destroy', :as => :logout
  # match '/login' => 'sessions#new', :as => 'login'
  # match '/signup' => 'registrations#new', :as => :signup

  # resources :users
  
  resources :categories, :except => [:index]
  resources :subscriptions, :only => [:create]
  
  resources :articles, :only => [:new, :create, :edit, :update]
  
  match '/new' => 'home#new', :as => 'new'
  match '/beta' => 'home#beta', :as => 'beta'
  match '/about' => 'home#about', :as => 'about'
  

  # Admin related
  match '/admin_data' => "admin_data/home#index"
  namespace :admin do
    
  end
  match '/admin' => 'admin/home#index'
  

  # Route for tools without the tool part
  #   ie: http://sitesusing.com/rails
  match '/:id' => 'tools#show'
end