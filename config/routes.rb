Plumboard::Application.routes.draw do

  devise_for :users, :controllers => { registrations: "registrations", sessions: "sessions", omniauth_callbacks: "users/omniauth_callbacks" } 
  
  devise_scope :user do
    get "signup" => "registrations#new", as: :new_user_registration
    post "signup" => "registrations#create", as: :user_registration
    get "signout" => "sessions#destroy", as: :destroy_user_session
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
    get '/users/auth/:provider/setup' => 'users/omniauth_callbacks#setup'
  end

  # resource defs
  resources :listings, except: [:new, :edit, :update, :create] do
    collection do
      get 'seller', 'follower'
    end
  end

  resources :settings, except: [:new, :show, :create, :edit, :destroy, :update]
  resources :users, except: [:new]

  resources :pictures, only: [:destroy]
  resources :posts

  resources :temp_listings, except: [:index] do
    member do
      put 'resubmit'
    end
  end

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

  # custom user routes to edit member info
  get "/settings/contact", to: "settings#contact" 
  get "/settings/password", to: "settings#password" 

  # specify routes for devise user after sign-in
  namespace :user do
    root :to => "users#show", :as => :user_root
  end

  root to: 'pages#home'
end
