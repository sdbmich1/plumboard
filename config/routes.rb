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
      get 'seller', 'follower', 'sold', 'category', 'location'
    end
  end

  resources :invoices do
    collection do
      get 'sent', 'received', 'get_pixi_price', 'autocomplete_user_first_name'
    end
    member do
      get 'pay'
    end
  end

  resources :posts, except: [:new, :edit, :update] do
    collection do
      get 'unread', 'sent'
      post 'reply'
    end
  end

  resources :settings, except: [:new, :show, :create, :edit, :destroy, :update]
  resources :users, except: [:new]
  resources :bank_accounts

  resources :pictures, only: [:destroy] do
    member do
      get 'display'
    end
  end

  resources :searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_listing_title
    end
  end

  resources :post_searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_post_content
    end
  end

  resources :advanced_searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_listing_title, :autocomplete_site_name
    end
  end

  resources :comments, only: [:index, :new, :create]

  resources :temp_listings, except: [:index] do
    collection do
      get :autocomplete_site_name, 'unposted'
    end
    member do
      put 'resubmit', 'submit'
    end
  end

  resources :categories, except: [:show] do
    collection do
      get 'inactive', 'manage'
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

  resources :pages, only: [:index]

  # custom routes
  get "/about", to: "pages#about" 
  get "/privacy", to: "pages#privacy" 
  get "/help", to: "pages#help" 
  get "/contact", to: "pages#contact" 
  get "/welcome", to: "pages#welcome" 
  get '/system/:class/:attachment/:id/:style/:filename', :to => 'pictures#asset'
  # get '/photos/:attachment/:id/:style/:filename', :to => 'pictures#display'
  # post "/listings/preview", to: "listings#preview", :via => :post, :as => :preview 

  # custom user routes to edit member info
  get "/settings/contact", to: "settings#contact" 
  get "/settings/password", to: "settings#password" 

  # specify routes for devise user after sign-in
  namespace :user do
    root :to => "users#show", :as => :user_root
  end

  # specify root route based on user sign in status
  root to: 'listings#index', :constraints => lambda {|r| r.env["warden"].authenticate? }
  root to: 'pages#home'

  # exception handling
  # match '/*path', :to => 'application#rescue_with_handler'
end
