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
  
  resources :bookmarks, :only => [:new, :create, :index, :show, :edit, :update, :destroy]
  resources :usings, :only => [:update, :create, :destroy]



  match '/auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:index, :create, :destroy]
  # match '/users/sign_in' => 'sessions#new', :host => Settings.ssl_root_domain, :protocol => Settings.ssl_schema, :as => 'sign_in'
  # match '/users/sign_up' => 'registrations#new', :host => Settings.ssl_root_domain, :protocol => Settings.ssl_schema, :as => 'sign_up'
  
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
  match '/sites/lineofthought' => 'sites#show', :as => 'lineofthought', :id => 'lineofthought'

  # Admin related
  namespace :admin do
    resources :jobs, :only => [:index]
    resources :users, :only => [:index]
    resource :home
  end
  match '/admin' => 'admin/home#index'
  
  match '/admin_data', :to => 'admin_data/home#index'
end