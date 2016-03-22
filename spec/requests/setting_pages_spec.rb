require 'spec_helper'

describe "Settings", :type => :feature do
  subject { page }

  describe "GET /settings as business" do
    it_should_behave_like 'setting_pages', 'business_user', 'admin', 'to', true, false
    it_should_behave_like 'setting_pages', 'contact_user', 'admin', 'not_to', false, false
    it_should_behave_like 'setting_pages', 'business_user', 'admin', 'to', true, true 
    it_should_behave_like 'setting_pages', 'contact_user', 'admin', 'not_to', false, true
  end
end
