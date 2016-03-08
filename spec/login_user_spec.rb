require 'spec_helper'

module LoginTestUser
  include Devise::TestHelpers 

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs).as_null_object
  end

  def mock_admin_user(stubs={})
    @mock_user ||= mock_model(User, stubs).as_null_object
    @mock_user.add_role(:admin)
  end

  def log_in_test_user
    attr = { :username => "Foobar", :email => "doineedit@foobar.com" }
    #mock up an authentication in warden as per http://www.michaelharrison.ws/weblog/?p=349
    request.env['warden'] = double(Warden, :authenticate => mock_user(attr),
                                         :authenticate! => mock_user(attr),
                                         :authenticate? => mock_user(attr))
  end

  def log_in_admin_user
    attr = { :username => "Foobar", :email => "doineedit@foobar.com" }
    #mock up an authentication in warden as per http://www.michaelharrison.ws/weblog/?p=349
    request.env['warden'] = double(Warden, :authenticate => mock_admin_user(attr),
                                         :authenticate! => mock_admin_user(attr),
                                         :authenticate? => mock_admin_user(attr))
  end
     
end
