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

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
    config.mock_with :rspec
    config.include Paperclip::Shoulda::Matchers
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
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      reset_email
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
      Warden.test_reset!
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
