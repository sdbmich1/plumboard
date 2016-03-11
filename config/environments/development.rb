Plumboard::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  # config.cache_store = :dalli_store, 'localhost.com:11211',
  #    { :namespace => 'Plumboard', :expires_in => 1.hour, :compress => true }

  # paperclip setting
  Paperclip.options[:command_path] = "/c/Windows/system32/convert"

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'localhost.com:3000' }
  config.action_mailer.asset_host = 'http://localhost.com:3000'

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
   
  # do not precompile assets
  config.serve_static_files = false

  # Expands the lines which load the assets
  config.assets.debug = false

  # paperclip storage setting
  PAPERCLIP_STORAGE_OPTIONS = {
  	  url: "/system/:class/:attachment/:id/:style/:filename",
  	  path: ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename" 
   }

  # facebook ssl setting
  FACEBOOK_SSL_OPTIONS = {:ca_path => "/etc/ssl/certs"}

  # add bullet for performance monitoring (eager loading)
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
end
