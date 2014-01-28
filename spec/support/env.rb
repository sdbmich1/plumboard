Capybara.register_driver :selenium do |app|
  require 'selenium/webdriver'
  Selenium::WebDriver::Firefox::Binary.path = "c:/RoRdev/Firefox"
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end
