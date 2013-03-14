RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  Devise.stretches = 1
end
