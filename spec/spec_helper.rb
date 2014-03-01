require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'email_spec'
  require 'rspec/autorun'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'database_cleaner'
  require "paperclip/matchers"
  require "cancan/matchers"
  require "thinking_sphinx/test"
  require 'balanced'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  host = ENV['BALANCED_HOST'] or nil
  options = {}

  if !host.nil? then
    options[:scheme] = 'http'
    options[:host] = host
    options[:port] = 5000
    options[:ssl_verify] = false
    Balanced.configure(nil, options)
  end

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
    config.mock_with :rspec
    config.include Paperclip::Shoulda::Matchers
    config.include Capybara::RSpecMatchers
    config.include Capybara::DSL, :type => :request
    config.include FactoryGirl::Syntax::Methods
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = false

    config.extend ControllerMacros, :type => :controller
    config.infer_base_class_for_anonymous_controllers = false
    config.include Rails.application.routes.url_helpers
    config.include(MailerMacros)  
    config.include IntegrationSpecHelper, :type => :request

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      if example.metadata[:js]
        DatabaseCleaner.strategy = :truncation
      else
	DatabaseCleaner.strategy = :transaction
      end

      reset_email
      DatabaseCleaner.start
      Contact.any_instance.stub(:geocode) { [1,1] }
      Listing.any_instance.stub(:geocode) { [1,1] }
    end

    config.after(:each) do
      DatabaseCleaner.clean
      Warden.test_reset!
    end

    def make_marketplace
      api_key = Balanced::ApiKey.new.save
      Balanced.configure api_key.secret
      Balanced::Marketplace.new.save
    end
  end
end

Capybara.default_host = 'http://example.org'
OmniAuth.config.test_mode = true
OmniAuth.config.add_mock :facebook, uid: "fb-12345", info: { name: "Bob Smith" }, extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',   
      email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } }

OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
     provider: 'facebook', uid: "fb-12345", info: { name: "Bob Smith" }, extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',   
     email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } }
})

Spork.each_run do
  FactoryGirl.reload
end
