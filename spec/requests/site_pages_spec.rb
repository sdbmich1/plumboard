require 'spec_helper'

feature "site" do
  subject { page }
  
  let(:user) { create(:contact_user) }
  let(:admin_user) { create(:admin, user_type_code: 'AD') }
  let(:site) { create(:site) }

  describe "Sites page" do
    before do
      create :site, name:"test"
      init_setup admin_user
      visit sites_path
    end

    it "has 'name' and 'type' and 'status' titles" do
      page.should have_content 'Name'
      page.should have_content 'Type'
      page.should have_content 'Status'
    end

    it "has export CSV button" do
      page.should have_link 'Export as CSV file' # , href: wanted_listings_path(loc: @site.id, cid: @category.id, format: 'csv')
    end

    it "has details button" do
      page.should have_link 'Details'
    end
  end
end
