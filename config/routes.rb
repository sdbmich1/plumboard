Plumboard::Application.routes.draw do
  devise_for :users, :controllers => { registrations: "registrations", sessions: "sessions", omniauth_callbacks: "users/omniauth_callbacks",
      confirmations: "confirmations" } 
  
  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
    get '/users/auth/:provider/setup' => 'users/omniauth_callbacks#setup'
  end

  # resource defs
  resources :listings, except: [:new, :edit, :create, :destroy] do
    collection do
      get 'pixi_price', 'seller', 'follower', 'category', 'local', 'wanted', 'purchased', 'invoiced', 'seller_wanted'
    end
    member do
      put 'repost'
    end
  end

  resources :invoices do
    collection do
      get 'sent', 'received', 'autocomplete_user_first_name'
    end
    member do
      get 'pay'
      put 'remove', 'decline'
    end
  end

  resources :posts, except: [:new, :edit, :create, :update, :show, :index] do
    member do
      put 'mark_read'
      put 'remove'
    end
    collection do
      get 'unread', 'mark'
    end
  end

  resources :conversations, except: [:new, :edit] do
    member do
      put 'remove'
    end
    collection do
      post 'reply'
    end
  end

  resources :settings, except: [:new, :show, :create, :edit, :destroy, :update]
  resources :users, except: [:new]
  resources :sites, except: [:destroy]

  resources :card_accounts, :bank_accounts, except: [:edit, :update] do
    collection do
      get :autocomplete_user_first_name
    end
  end

  resources :pixi_posts do
    collection do
      get 'seller', 'pixter', 'pixter_report',  :autocomplete_site_name, :autocomplete_user_first_name
    end
    member do
      get 'reschedule'
    end
  end

  resources :pixi_post_zips, except: [:new, :show, :create, :edit, :destroy, :update, :index] do
    collection do
      get 'submit', 'check',  :autocomplete_pixi_post_zip_zip
    end
  end

  resources :pictures, only: [:show, :create, :destroy] do
    member do
      get 'display'
    end
  end

  resources :searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_listing_title
      post :locate
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

  resources :site_searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_site_name
    end
  end

  resources :user_searches, except: [:new, :edit, :update, :create, :destroy, :show] do
    collection do
      get :autocomplete_user_first_name
    end
  end

  resources :promo_code_searches, only: [:index]
  resources :comments, only: [:index, :new, :create]
  resources :ratings, only: [:index, :new, :create]

  resources :temp_listings do
    collection do
      get :autocomplete_site_name, :autocomplete_user_business_name, :autocomplete_user_first_name, 'unposted', 'pending', 'invoiced'
    end
    member do
      put 'resubmit', 'submit'
    end
  end

  resources :categories do
    collection do
      get 'inactive', 'manage', :autocomplete_site_name, 'category_type', 'location'
    end
  end

  resources :pending_listings, except: [:new, :edit, :update, :create, :destroy] do
    member do
      put 'approve', 'deny'
    end
  end
  
  resources :transactions, except: [:destroy, :edit, :update] do
    get 'refund', :on => :member
  end

  resources :inquiries do
    collection do
      get 'closed'
    end
  end

  namespace :api do
    namespace :v1  do
      resources :sessions, only: [:create, :destroy]
      resources :registrations, only: [:create]
      resources :devices, only: [:create]
    end
  end

  namespace :stripe do
    resources :webhooks, only: [:create]
  end

  resources :pages, only: [:index] do
    get 'location_name', 'location_id', :on => :collection
  end

  resources :pixi_likes, only: [:create, :destroy]
  resources :saved_listings, only: [:create, :index, :destroy]
  resources :favorite_sellers, only: [:create, :index, :update]
  resources :shop_locals, only: [:index]
  resources :pixi_wants, only: [:create] do
    post 'buy_now', :on => :collection
  end

  resources :subscriptions
  resources :promo_codes

  # custom routes
  get "/about", to: "pages#about" 
  get "/privacy", to: "pages#privacy" 
  get "/help", to: "pages#help" 
  get "/terms", to: "pages#terms" 
  get "/howitworks", to: "pages#howitworks" 
  get "/welcome", to: "pages#welcome" 
  get "/giveaway", to: "pages#giveaway" 
  get "/support", to: "inquiries#support" 
  get "/contact", to: "inquiries#new" 
  get '/system/:class/:attachment/:id/:style/:filename', :to => 'pictures#asset'
  get '/loc_name', to: "sites#loc_name"
  get '/buyer_name', to: "users#buyer_name"
  get '/states', to: "users#states"
  # get '/photos/:attachment/:id/:style/:filename', :to => 'pictures#display'
  put '/submit', to: "temp_listings#submit"
  put '/resubmit', to: "temp_listings#resubmit"

  # custom user routes to edit member info
  get "/settings/contact", to: "settings#contact" 
  get "/settings/details", to: "settings#details" 
  get "/settings/password", to: "settings#password" 
  get "/settings/delivery", to: "settings#delivery" 

  # personalized paths
  get '/biz/:url' => "listings#biz", as: :biz
  get '/mbr/:url' => "listings#mbr", as: :mbr
  get '/pub/:url' => "listings#pub", as: :pub
  get '/edu/:url' => "listings#edu", as: :edu
  get '/loc/:url' => "listings#loc", as: :loc
  get '/careers' => "listings#career", as: :career

  # subdomain
  constraints(Subdomain) do
    get '/' => 'shop_locals#index'
  end

  # specify root route based on user sign in status
  authenticated :user do
    root to: 'listings#local', as: :authenticated_root
  end
  unauthenticated do
    root to: 'pages#home'
  end

  # exception handling
  # match '/*path', :to => 'application#rescue_with_handler'
end
