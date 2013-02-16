source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'rake' 
 
# use devise for user authenication
gem 'devise'

# use mysql as db
gem "mysql2", "~> 0.3.11"

# add paperclip for photos
gem 'paperclip'

# add thinking sphinx
gem 'thinking-sphinx', '2.0.10'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '3.2.5'
  gem 'coffee-rails', '3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '1.2.3'
end

gem 'jquery-rails', '2.0.2'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger
# gem 'debugger'

# add payment gateways
gem 'activemerchant'
gem 'stripe'

# install oauth
gem 'omniauth'

# add facebook & twitter
gem "omniauth-facebook", '1.4.0'
gem "omniauth-twitter"
gem "omniauth-github"
gem "omniauth-openid"

# facebook graph
gem "fb_graph", '~> 1.8.4' #"~> 2.4.6"

# add form validations 
gem 'client_side_validations'  

# datetime validations
gem 'validates_timeliness', '~> 3.0'

# add sass
gem 'bootstrap-sass', '2.1'

group :development, :test do
  # gem 'wdm', '~> 0.0.3'
  gem 'wdm', :platforms => [:mswin, :mingw], :require => false
  gem 'rspec-rails', '2.11.0'
  gem 'guard-rspec', '1.2.1'
  gem 'guard-spork', '1.4.2'
  gem 'spork', '0.9.2'
end

# test gems
group :test do
  gem 'factory_girl_rails'
  gem 'capybara', '1.1.2'
  gem 'rb-fchange', '0.0.5'
  gem 'rb-notifu', '0.0.4'
  gem 'win32console', '1.3.0'
  gem 'email_spec'
  gem 'launchy'
  gem 'faker'
  gem "database_cleaner"
end

# production gems
group :production do

   # handle exceptions
   gem 'exception_notification', :require => 'exception_notifier'

   # google analytics
   gem 'rack-google_analytics', :require => "rack/google_analytics"
end 
