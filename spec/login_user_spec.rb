require 'spec_helper'

module LoginTestUser
  include Devise::TestHelpers 

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs).as_null_object
  end

  def log_in_test_user
    attr = { :username => "Foobar", :email => "doineedit@foobar.com" }
    #mock up an authentication in warden as per http://www.michaelharrison.ws/weblog/?p=349
    request.env['warden'] = mock(Warden, :authenticate => mock_user(attr),
                                         :authenticate! => mock_user(attr),
                                         :authenticate? => mock_user(attr))
  end
     
end