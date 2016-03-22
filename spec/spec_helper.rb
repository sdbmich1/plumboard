require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'email_spec'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'database_cleaner'
  require "paperclip/matchers"
  require "cancan/matchers"
  require "thinking_sphinx/test"
  require "rack_session_access/capybara"

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # turn off sphinx
  ThinkingSphinx::Deltas.suspend!

  host = ENV['BALANCED_HOST'] or nil
  options = {}

  if !host.nil? then
    options[:scheme] = 'http'
    options[:host] = host
    options[:port] = 5000
    options[:ssl_verify] = false
  end


  RSpec.configure do |config|
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
    config.mock_with :rspec
    config.include Paperclip::Shoulda::Matchers
    config.include PaperclipStub
    config.include Capybara::RSpecMatchers
    config.include Capybara::DSL, :type => :request
    config.include FactoryGirl::Syntax::Methods
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = false
    config.extend ControllerMacros, :type => :controller
    config.infer_base_class_for_anonymous_controllers = false
    config.infer_spec_type_from_file_location!
    config.include Rails.application.routes.url_helpers
    config.include(MailerMacros)  
    config.include IntegrationSpecHelper, :type => :request
    config.include SphinxHelpers, type: :feature
    config.include Requests::JsonHelpers, type: :request
    # config.include TokenInputHelper, :type => :feature

    config.before(:suite) do
      DatabaseCleaner.clean_with :truncation
#      ThinkingSphinx::Test.init
#      ThinkingSphinx::Test.start_with_autostop  # stop Sphinx at the end of the test suite.
    end

    config.before(:each) do
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
      # page.driver.browser.manage.window.maximize
    end

    config.before(:each) do
      DatabaseCleaner.start
      set_selenium_window_size(1250, 800) if Capybara.current_driver == :selenium
      reset_email
      allow_any_instance_of(Contact).to receive(:geocode) { [1,1] }
      allow_any_instance_of(Listing).to receive(:geocode) { [1,1] }
      allow_any_instance_of(User).to receive(:geocode).and_return([1,1]) 
      AWS.stub!
    end

    config.append_after(:each) do
      DatabaseCleaner.clean
    end

    config.after(:each) do
      Warden.test_reset!
    end

    def make_marketplace
      api_key = Balanced::ApiKey.new.save
      Balanced.configure api_key.secret
      Balanced::Marketplace.new.save
    end
  end
end

Capybara.register_driver :selenium_with_long_timeout do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = 180
  driver = Capybara::Selenium::Driver.new(app, :browser => :firefox, :http_client => client)
  driver.browser.manage.window.maximize
  driver
end

Capybara.javascript_driver = :selenium_with_long_timeout
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
