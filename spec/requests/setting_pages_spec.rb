require 'spec_helper'

describe "Settings", :type => :feature do
  subject { page }

  describe "GET /settings as business" do
    it_should_behave_like 'setting_pages', 'business_user', 'admin', 'should', true, false
    it_should_behave_like 'setting_pages', 'contact_user', 'admin', 'should_not', false, false
    it_should_behave_like 'setting_pages', 'business_user', 'admin', 'should', true, true 
    it_should_behave_like 'setting_pages', 'contact_user', 'admin', 'should_not', false, true
  end
end
