source 'http://rubygems.org'

gem 'rails', '4.2.6'
gem 'rake', '~> 10.4', '>= 10.4.2'

# bring back things removed in Rails 4
gem 'protected_attributes', '1.1.3'
gem 'rails-observers'
gem 'activerecord-session_store'
gem 'responders'

#added faraday gem version 0.8.9 to run smoothly on Mac
gem 'faraday', '0.8.9'
 
# use devise for user authenication
gem 'devise', '~> 3.5.6'
gem 'devise-token_authenticatable'

# add delayed job
gem 'delayed_job_active_record', '4.1.0'
gem "daemons"

# process devise mails in background
gem 'devise-async'

# use mysql as db
gem "mysql2", "~> 0.3.20"

# add paperclip for photos
gem 'paperclip', '~> 4.3.5'
gem 'delayed_paperclip', '~> 2.7.1'

# add for ajax uploads
gem 'remotipart', '~> 1.0'

# add thinking sphinx
gem 'thinking-sphinx', '~> 3.1.4' 

# add roles
gem 'rolify', '~> 4.1.1'
gem 'cancan'

# add clickable links for comment text
gem 'rinku', '~> 1.7.3'

# used to mark messages as read/unread
gem 'unread', '0.7.1'

# jquery
gem 'jquery-rails', '~> 3.1.2'

gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'compass-rails', '2.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '>= 1.3.0'
gem 'jquery-ui-rails', '~> 4.0', '>= 4.0.2'
gem 'jquery-ui-themes'

# add datepicker
gem 'bootstrap-datepicker-rails', '1.5.0'

# add autocomplete
gem 'rails4-autocomplete'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '3.1.5', :require => 'bcrypt'
gem 'bcrypt'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Use thin as the development app server
gem 'thin'

# add whenever for cron jobs
gem 'whenever'

# amazon aws
gem 'aws-sdk', '~> 1.66'
#gem 'aws-s3', :require => 'aws/s3'

# picture upload for s3
gem 's3_file_field', github: 'lastobelus/s3_file_field', ref: 'b7ebbbbae7c84435020dd509d5dec48d78d90c14'

# To use debugger
# gem 'debugger'

# add payment gateways
gem 'activemerchant'
gem 'stripe', '~> 1.21.0'
# gem 'balanced', "~> 0.8.1"

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
gem 'client_side_validations', '4.2.0'

# datetime validations
gem 'jc-validates_timeliness'

# time select
gem "combined_time_select", "~> 1.0.1"

# get timezone
gem 'timezone', '~> 0.3.2'

# add country selection
gem 'country_select'

# add geocoder
gem 'geocoder', '~> 1.3', '>= 1.3.1'

# add images
gem 'rmagick', '~> 2.15', '>= 2.15.4'

# pagination
gem 'will_paginate', '~> 3.1.0'
gem 'bootstrap-will_paginate', '0.0.10'

# add sass
gem 'bootstrap-sass', '~> 2.3.2.1'

# add memcached
gem 'dalli'
gem 'dalli-elasticache'

# add area
gem 'area', '~> 0.10.0'

# client validation
gem "parsley-rails", '~> 2.0.5.0'

# handle https uri
gem 'open_uri_redirections'

# needed for dependencies
gem 'sprockets', '~> 2.8'
gem 'ffi'
gem 'money', '~> 6.7'

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
  gem 'bullet', '~> 5.0'
  # gem 'web-console'
end

group :development, :test do
  gem 'wdm', '~> 0.1.1', :platforms => [:mswin, :mingw], :require => false
  gem 'tzinfo-data', platforms: [:mingw, :mswin]
  gem 'rspec-rails', '3.4.2'
  gem 'rspec-its'
  gem 'rspec-activemodel-mocks'
  gem 'guard-rspec', '4.3.1'
  gem 'guard-spork', '2.0.2'
  gem 'spork', '~> 1.0rc'
  gem 'ffaker'
  gem "vcr", "~> 2.5.0"
  gem 'rack_session_access'
  gem 'minitest', '~> 5.1'
end

# test gems
group :test do
  gem 'factory_girl_rails'
  gem 'capybara', '2.6.2'
  gem 'rb-fchange', '0.0.5', :platforms => [:mswin, :mingw], :require => false
  gem 'rb-notifu', '0.0.4'
  gem 'win32console', '~> 1.3.2', :platforms => [:mswin, :mingw], :require => false
  gem 'email_spec'
  gem 'launchy'
  gem "database_cleaner", "~> 1.5.1"
  gem 'connection_pool'
  gem 'selenium-webdriver', '~> 2.48.1'
  gem 'shoulda-matchers', '2.8.0'
  # gem "webmock", "~> 1.11.0"
  gem "fakeweb", "~> 1.3"
  gem 'test_after_commit', '~> 0.4.0'
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
gem 'excon', '~> 0.45'
gem 'rubber', '~> 3.2', '>= 3.2.1'
gem 'fog', '~> 1.37'
gem 'recursive-open-struct'
gem 'lazyload-rails'

# standardize all modals
gem 'data-confirm-modal', github: 'ifad/data-confirm-modal', branch: 'bootstrap2'

gem 'eventmachine', '~> 1.0.3'
gem 'nokogiri', '~> 1.6.0'
gem 'net-ssh', '~> 2.9', '>= 2.9.3.beta1'
gem 'rack-cors'
