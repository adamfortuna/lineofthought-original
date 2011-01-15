Snaps::Application.routes.draw do
  match '/' => 'home#index', :as => 'root'
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  match '/signup' => 'registrations#new', :as => :signup

  # match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
  # devise_for :sessions
  # resources :authentications

  resources :users
  
  resources :categories
  
  resources :tools do
    collection do 
      get :autocomplete
    end
  end

  resources :sites do
    resource :tools , :controller => "sites_tools", :only => [:index, :edit, :create, :destroy]
  end
  
  match '/about' => 'home#about', :as => 'about'
  match '/:id' => 'tools#show'
  
end