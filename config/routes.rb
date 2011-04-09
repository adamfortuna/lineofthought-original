Snaps::Application.routes.draw do
  match '/' => 'home#index', :as => 'root'
  match '/search' => 'search#index', :as => 'search'

  resources :tools do
    collection do 
      get :autocomplete
      post :lookup
      get :autocomplete_example
    end
    member do
      get :bookmarks
    end
    resources :sites, :controller => "tool_sites", :only => [:create] do
      collection do
        get :autocomplete, :deleted
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
        get :autocomplete, :deleted
      end
    end
  end
  
  resources :bookmarks, :only => [:new, :create, :index, :show, :edit, :update, :destroy] do
    collection do
      post :lookup
    end
    resource :save, :controller => "saved_bookmark", :only => [:new, :create, :edit, :update, :destroy]
  end
  resources :usings, :only => [:update, :create, :destroy]
  post '/versions/revert' => "versions#revert", :as => "revert_version"



  match '/auth/:provider/callback' => 'authentications#create' #, :host => Settings.ssl_root_domain, :protocol => Settings.ssl_schema
  match '/auth/failure' => 'authentications#failure' #, :host => Settings.ssl_root_domain, :protocol => Settings.ssl_schema
  resources :authentications, :only => [:index, :create, :destroy]
  # match '/users/sign_in' => 'sessions#new', :host => Settings.ssl_root_domain, :protocol => Settings.ssl_schema, :as => 'sign_in'
  # match '/users/sign_up' => 'registrations#new', :host => Settings.ssl_root_domain, :protocol => Settings.ssl_schema, :as => 'sign_up'
  
  devise_for :users, :only => [:new, :create, :edit, :update],
    :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
  
  resource :account, :only => [:edit, :update]
  resources :profiles, :only => [:show] do
    member do
      get :sites
      get :tools
      get :bookmarks
    end
  end

  resources :subscriptions, :only => [:index, :new, :create]
  resources :invites, :only => [:index, :create]
  
  match '/about' => 'home#about',                   :as => 'about'
  match '/stream' => 'home#stream',                 :as => 'stream'
  match '/welcome' => 'home#welcome',               :as => 'welcome'
  match '/license' => 'home#license',               :as => 'license'

  match '/lookup' => 'lookup#new',                  :as => 'lookup'
  match '/sites/lineofthought' => 'sites#show',     :as => 'lineofthought', :id => 'lineofthought'

  match '/tour' => 'tour#index',                    :as => 'tour'
  match '/tour/sites' => 'tour#sites',              :as => 'sites_tour'
  match '/tour/tools' => 'tour#tools',              :as => 'tools_tour'
  match '/tour/bookmarks' => 'tour#bookmarks',      :as => 'bookmarks_tour'
  match '/tour/permissions' => 'tour#permissions',  :as => 'permissions_tour'

  # Admin related
  namespace :admin do
    resources :jobs, :only => [:index]
    resources :users, :only => [:index]
    resource :home
  end
  match '/admin' => 'admin/home#index'
  
  match '/admin_data', :to => 'admin_data/home#index'
end