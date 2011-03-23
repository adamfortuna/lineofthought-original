Snaps::Application.routes.draw do
  match '/' => 'home#index', :as => 'root'

  resources :tools do
    collection do 
      get :autocomplete
      post :lookup
    end
    member do
      get :bookmarks
    end
    resources :sites, :controller => "tool_sites", :only => [:create] do
      collection do
        get :autocomplete, :manage
      end
    end
  end

  resources :sites do
    collection do 
      get :autocomplete
    end
    member do
      get :bookmarks
    end
    resources :claims, :controller => "site_claims", :only => [:new, :create]
    resources :tools, :controller => "site_tools", :only => [:create, :show] do
      collection do 
        get :autocomplete, :manage
      end
    end
  end
  
  resources :bookmarks, :only => [:new, :create, :index, :show, :edit, :update, :destroy] do
    collection do
      post :lookup
    end
  end
  resources :usings, :only => [:update, :create, :destroy]



  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :only => [:new, :create, :edit, :update],
    :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
  
  resources :profiles, :only => [:show] do
    member do
      get :sites
      get :tools
      get :bookmarks
    end
  end

  resources :subscriptions, :only => [:index, :create]
  
  match '/new' => 'home#new', :as => 'new'
  match '/beta' => 'home#beta', :as => 'beta'
  match '/about' => 'home#about', :as => 'about'
  match '/fail' => 'home#fail', :as => 'fail'
  match '/lookup' => 'lookup#new', :as => 'lookup'

  # Admin related
  match '/admin_data' => "admin_data/home#index"
  namespace :admin do
    resources :jobs, :only => [:index]
    resources :users, :only => [:index]
    resource :home
  end
  match '/admin' => 'admin/home#index'
  

  # Route for tools without the tool part
  #   ie: http://sitesusing.com/rails
  match '/:id' => 'tools#show'
end