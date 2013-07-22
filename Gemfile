source 'http://rubygems.org'

gem 'rails', '3.2.12'
gem 'rake' 
 
# use devise for user authenication
gem 'devise'

# use mysql as db
gem "mysql2", "~> 0.3.12"

# add paperclip for photos
gem 'paperclip'

# add for ajax uploads
gem 'remotipart', '~> 1.0'

# add thinking sphinx
gem 'thinking-sphinx', '~> 3.0.2'

# add roles
gem 'rolify'
gem 'cancan'

# add clickable links for comment text
gem 'rinku'

# used to mark messages as read/unread
gem 'unread'

gem 'jquery-rails', '~> 2.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '3.2.5'
  gem 'coffee-rails', '3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '1.2.3'
  gem 'jquery-ui-rails'
  gem 'jquery-ui-themes'
end

# add datepicker
gem 'bootstrap-datepicker-rails'

# add autocomplete
gem 'rails3-jquery-autocomplete'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Use thin as the development app server
gem 'thin'

# add whenever for cron jobs
gem 'whenever'

# amazon aws
gem "aws-sdk", "~> 1.11.3"
#gem 'aws-s3', :require => 'aws/s3'

# To use debugger
# gem 'debugger'

# add payment gateways
gem 'activemerchant'
gem 'stripe'
gem 'balanced', "~> 0.7.1"

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

# time select
gem "combined_time_select", "~> 1.0.1"

# add country selection
gem 'country_select'

# add geocoder
gem "geocoder", "~> 1.1.8"

# add images
gem "rmagick", "~> 2.13.1"

# pagination
gem 'will_paginate', '~> 3.0'
gem 'bootstrap-will_paginate', '0.0.6'

# add sass
gem 'bootstrap-sass', '2.1'

# development gems
group :development do
  gem 'better_errors'
  gem 'binding_of_caller'

  # Deploy with Capistrano
  gem 'capistrano'

  # Capistrano RVM integration
  gem 'rvm-capistrano'
end

group :development, :test, :staging do
  gem 'wdm', '~> 0.1.0', :platforms => [:mswin, :mingw], :require => false
  # gem 'wdm', :platforms => [:mswin, :mingw], :require => false
  gem 'rspec-rails', '2.12.0'
  gem 'guard-rspec', '1.2.1'
  gem 'guard-spork', '1.4.2'
  gem 'spork', '0.9.2'
  gem 'faker'
  gem "vcr", "~> 2.5.0"
end

# test gems
group :test do
  gem 'factory_girl_rails'
  gem 'capybara', '1.1.2'
  gem 'rb-fchange', '0.0.5'
  gem 'rb-notifu', '0.0.4'
  gem 'win32console', '~> 1.3.2', :platforms => [:mswin, :mingw], :require => false
  gem 'email_spec'
  gem 'launchy'
  gem "database_cleaner"
  gem 'connection_pool'
  gem 'selenium-webdriver'
  # gem "webmock", "~> 1.11.0"
  gem "fakeweb", "~> 1.3"
end

# production gems
group :production do

   # handle exceptions
   gem 'exception_notification', :require => 'exception_notifier'

   # google analytics
   gem 'rack-google_analytics', :require => "rack/google_analytics"
end 

gem 'rubber'
gem 'open4'
gem 'gelf'
gem 'graylog2_exceptions', :git => 'git://github.com/wr0ngway/graylog2_exceptions.git'
gem 'graylog2-resque'
gem 'excon', '~> 0.21.0'
