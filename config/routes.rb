Snaps::Application.routes.draw do
  match '/' => 'home#index', :as => 'root'

  resources :tools do
    collection do 
      get :autocomplete
      post :lookup
    end
    member do
      get :bookmarks, :books, :jobs
    end
    resources :sites, :controller => "tool_sites", :only => [:index, :new, :create]
  end

  resources :sites do
    collection do 
      get :autocomplete
    end
    member do
      get :bookmarks
    end
    resources :claims, :controller => "site_claims", :only => [:new, :create]
    resources :tools, :controller => "site_tools", :only => [:index, :create, :show] do
      collection do 
        get :autocomplete, :manage
      end
    end
  end
  
  resources :bookmarks, :only => [:new, :create, :index, :show, :edit, :update]
  resources :usings, :only => [:update, :create, :destroy]

  # resources :jobs
#  resources :books

  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :only => [:new, :create, :edit, :update],
    :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
    
  # match '/logout' => 'sessions#destroy', :as => :logout
  # match '/login' => 'sessions#new', :as => 'login'
  # match '/signup' => 'registrations#new', :as => :signup

  # resources :users
  
  resources :categories, :only => [:show]
  resources :subscriptions, :only => [:create]
  
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