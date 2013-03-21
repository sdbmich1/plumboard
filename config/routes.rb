Plumboard::Application.routes.draw do

  devise_for :users, :controllers => { registrations: "registrations", sessions: "sessions" } 
  
  devise_scope :user do
    get "signup" => "registrations#new", as: :new_user_registration
    post "signup" => "registrations#create", as: :user_registration
    get "signout" => "sessions#destroy", as: :destroy_user_session
  end

  # resource defs
  resources :listings, except: [:new] do
    collection do
      get 'seller', 'follower'
    end
  end

  resources :users, except: [:new]
  resources :temp_listings, except: [:index] 

  resources :pending_listings, except: [:new, :edit, :update, :create, :destroy] do
    member do
      put 'approve', 'deny'
    end
  end
  
  resources :transactions do
    get 'refund', :on => :member
  end

  # custom routes
  get "/about", to: "pages#about" 
  get "/privacy", to: "pages#privacy" 
  get "/help", to: "pages#help" 
  get "/contact", to: "pages#contact" 
  get "/welcome", to: "pages#welcome" 
  get '/system/:class/:attachment/:id/:style/:filename', :to => 'pictures#asset'
  # post "/listings/preview", to: "listings#preview", :via => :post, :as => :preview 
  # put "/pending_listings/approve/:id", to: "pending_listings#approve", :via => :put, :as => :approve 
  # put "/pending_listings/deny/:id", to: "pending_listings#deny", :via => :put, :as => :deny 

  # specify routes for devise user after sign-in
  namespace :user do
    root :to => "users#show", :as => :user_root
  end

  root to: 'pages#home'
end
