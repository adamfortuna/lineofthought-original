Snaps::Application.routes.draw do
  match '/' => 'home#index', :as => 'root'

  resources :tools, :except => :destroy do
    resources :sites, :controller => "tool_sites", :only => [:index, :new, :create]
    collection do 
      get :lookup
    end
  end

  resources :sites do
    resource :tools, :controller => "sites_tools", :only => [:index, :edit, :create, :destroy] do
      collection do 
        get :autocomplete
      end
    end
  end


  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :only => [:new, :create, :edit, :update],
    :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
    
  # match '/logout' => 'sessions#destroy', :as => :logout
  # match '/login' => 'sessions#new', :as => 'login'
  # match '/signup' => 'registrations#new', :as => :signup

  # resources :users
  
  resources :categories, :except => [:index]
  resources :subscriptions, :only => [:create]
  
  match '/new' => 'home#new', :as => 'new'
  match '/beta' => 'home#beta', :as => 'beta'
  match '/about' => 'home#about', :as => 'about'
  

  # Route for tools without the tool part
  #   ie: http://sitesusing.com/rails
  match '/admin_data' => "admin_data/home#index"
  match '/:id' => 'tools#show'
end