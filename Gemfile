source 'http://rubygems.org'

gem 'rails', '3.2.12'
gem 'rake', '~> 10.3.1' 

#added faraday gem version 0.8.9 to run smoothly on Mac
gem 'faraday', '0.8.9'
 
# use devise for user authenication
gem 'devise'

# add delayed job
gem 'delayed_job_active_record'
gem "daemons"

# process devise mails in background
gem 'devise-async'

# use mysql as db
gem "mysql2", "~> 0.3.12"

# add paperclip for photos
gem 'paperclip'
gem 'delayed_paperclip', '~> 2.7.1'

# add for ajax uploads
gem 'remotipart', '~> 1.0'

# add thinking sphinx
gem 'thinking-sphinx', '~> 3.0.6' 

# add roles
gem 'rolify'
gem 'cancan'

# add clickable links for comment text
gem 'rinku', '~> 1.7.3'

# used to mark messages as read/unread
gem 'unread'

# jquery
gem 'jquery-rails', '~> 3.1.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '3.2.5'
  gem 'coffee-rails', '3.2.2'
  gem 'compass-rails', '~> 1.1.7'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '1.2.3'
  gem 'jquery-ui-rails'
  gem 'jquery-ui-themes'
  gem 'turbo-sprockets-rails3'
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

# picture upload for s3
gem 's3_file_field', github: 'lastobelus/s3_file_field', ref: 'b7ebbbbae7c84435020dd509d5dec48d78d90c14'

# To use debugger
# gem 'debugger'

# add payment gateways
gem 'activemerchant'
gem 'stripe'
gem 'balanced', "~> 0.8.1"

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

# get timezone
gem 'timezone', '~> 0.3.2'

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
gem 'bootstrap-sass', '~> 2.3.2.1'

# add memcached
gem 'dalli'
gem 'dalli-elasticache'

#add cache digests for russian doll caching
gem 'cache_digests', '~> 0.3.1'

# add area
gem 'area', '~> 0.10.0'

# client validation
gem "parsley-rails", '~> 2.0.5.0'

# handle https uri
gem 'open_uri_redirections'

# development gems
group :development do
  gem 'better_errors', '~> 1.1.0'
  gem 'binding_of_caller'

  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-maintenance'

  # Capistrano RVM integration
  gem 'rvm-capistrano', :require => false

  gem 'quiet_assets'
  gem 'bullet'
end

group :development, :test do
  gem 'wdm', '~> 0.1.0', :platforms => [:mswin, :mingw], :require => false
  # gem 'wdm', :platforms => [:mswin, :mingw], :require => false
  gem 'rspec-rails', '2.13.0'
  gem 'guard-rspec', '3.0.2'
  gem 'guard-spork', '1.5.1'
  gem 'spork', '~> 1.0rc'
  gem 'faker'
  gem "vcr", "~> 2.5.0"
  gem 'rack_session_access'
end

# test gems
group :test do
  gem 'factory_girl_rails'
  gem 'capybara', '1.1.2'
  gem 'rb-fchange', '0.0.5', :platforms => [:mswin, :mingw], :require => false
  gem 'rb-notifu', '0.0.4'
  gem 'win32console', '~> 1.3.2', :platforms => [:mswin, :mingw], :require => false
  gem 'email_spec'
  gem 'launchy'
  gem "database_cleaner"
  gem 'connection_pool'
  gem 'selenium-webdriver', '~> 2.45.0'
  gem 'shoulda-matchers'
  # gem "webmock", "~> 1.11.0"
  gem "fakeweb", "~> 1.3"
  gem 'test_after_commit'
end

# production gems
group :production, :staging do

   # handle exceptions
   gem 'exception_notification', "~> 3.0.1", :require => 'exception_notifier'
end

# production gems
group :production do

   # google analytics
   gem 'rack-google_analytics', :require => "rack/google_analytics"
end 

gem 'as_csv'
gem 'open4'
gem 'gelf'
gem 'graylog2_exceptions', :git => 'git://github.com/wr0ngway/graylog2_exceptions.git'
gem 'graylog2-resque'
gem 'excon', '~> 0.21.0'
gem 'rubber'
gem 'recursive-open-struct'
gem 'lazyload-rails'

# standardize all modals
gem 'data-confirm-modal', github: 'ifad/data-confirm-modal', branch: 'bootstrap2'
