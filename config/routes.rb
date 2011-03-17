Snaps::Application.routes.draw do
  match '/' => 'home#index', :as => 'root'

  resources :tools do
    collection do 
      get :autocomplete
      post :lookup
    end
    resources :sites, :controller => "tool_sites", :only => [:index, :new, :create] do
      collection do
        get :autocomplete, :manage
      end
    end
    resources :bookmarks, :controller => "tool_bookmarks", :only => [:index]
  end

  resources :sites do
    collection do 
      get :autocomplete
    end
    resources :claims, :controller => "site_claims", :only => [:new, :create]
    resources :tools, :controller => "site_tools", :only => [:index, :create, :show] do
      collection do 
        get :autocomplete, :manage
      end
    end
  end
  
  resources :bookmarks, :only => [:new, :create, :index, :show, :edit, :update] do
    collection do
      post :lookup
    end
  end
  resources :usings, :only => [:update, :create, :destroy]

  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :only => [:new, :create, :edit, :update],
    :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
  
  resources :categories, :only => [:show]
  resources :subscriptions, :only => [:index, :create]
  
  match '/new' => 'home#new', :as => 'new'
  match '/beta' => 'home#beta', :as => 'beta'
  match '/about' => 'home#about', :as => 'about'
  

  # Admin related
  match '/admin_data' => "admin_data/home#index"
  namespace :admin do
    resources :jobs, :only => [:index]
    resource :home
  end
  match '/admin' => 'admin/home#index'
  

  # Route for tools without the tool part
  #   ie: http://sitesusing.com/rails
  match '/:id' => 'tools#show'
end