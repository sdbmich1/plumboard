require 'spec_helper'

feature "site" do
  subject { page }
  
  let(:admin_user) { create(:admin, user_type_code: 'AD') }
  
  # load records needed in collection_select dropdown menu
  def populate_collection_select_fields
    create :state, state_name: 'California', code: 'CA'
    create :site_type, description: 'City', code: 'city', status: 'active', hide: 'no'
  end

  def test_navbar(has_site_type=true)
    ['Active', 'Inactive', 'Create'].each do |link|
      page.should have_link link
    end
    if has_site_type
      page.should have_selector '#site_type'
    else
      page.should_not have_selector '#site_type'
    end
  end

  describe "Sites page" do
    def test_table
      ['Name', 'URL', 'Type', 'Status', 'Last Updated'].each do |column|
        page.should have_content column
      end
      page.should have_link 'Details'
      page.should_not have_content 'No sites found.'
    end

    def load_site_type_codes
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task["load_site_type_codes"].invoke
      SiteType.pluck(:code)
    end

    before do
      create :site, name: 'test', site_type_code: 'region'
      init_setup admin_user
      visit sites_path(status: 'active', stype: 'region')
    end

    it "renders active" do
      test_navbar
      test_table
    end

    it "renders inactive" do
      create :site, name: 'test', status: 'inactive', site_type_code: 'region'
      click_link('Inactive')
      test_navbar
      test_table
    end

    it "toggles site type", js: true do
      site_type_codes = load_site_type_codes
      site_type_codes.each do |stype|
        site = create :site, name: stype, status: 'active', site_type_code: stype
        visit sites_path(status: 'active', stype: stype)
        page.should have_content site.name
        test_navbar
        test_table
      end
    end

    it "displays 'No sites found.' if there are no sites" do
      click_link('Inactive')
      test_navbar
      page.should have_content 'No sites found.'
    end

    it "paginates" do
      15.times do
        create :site, name: 'test', site_type_code: 'region'
      end
      visit sites_path(status: 'active', stype: 'region')
      page.should have_content 'Displaying sites'
      page.should have_selector('div.pagination')
      click_link '2'
      test_navbar
      test_table
    end
  end

  describe "Show Site" do
    before do
      @site = create :site, name: 'test'
      @site.contacts.create(city: 'Test', state: 'CA')
      init_setup admin_user
      visit site_path(@site)
    end

    it "displays banner" do
      page.should have_content @site.name
      page.should have_css '.item-container'
      page.should have_css '.camera'
    end

    it "displays details" do
      ['Name', 'Description', 'URL', 'Status', 'Address',
       'Latitude, Longitude', 'Last Updated'].each do |attribute|
        page.should have_content attribute
      end
    end

    it "displays buttons" do
      page.should have_link 'Edit'
      page.should have_link 'Done'
    end

    it "displays navbar" do
      test_navbar(false)
    end
  end

  describe "Create Site" do
    before do
      populate_collection_select_fields
      init_setup admin_user
      visit sites_path(status: 'active', stype: 'region')
      click_link 'Create'
    end

    it "creates a Site" do
      find("input[placeholder='Site Name']").set "Test Site"
      find("input[placeholder='Site Description']").set "Test"
      find("input[placeholder='Site URL']").set "test"
      find("option[value='active']").select_option
      find("option[value='city']").select_option
      find("input[placeholder='Address']").set '1 California Street'
      find("input[placeholder='City']").set 'San Francisco'
      find("option[value='CA']").select_option
      find("input[placeholder='Zip']").set '94111'
      expect{ click_button 'Save Changes'; sleep 15 }.to change{ Site.count }.by(1)
    end

    it "displays navbar" do
      test_navbar(false)
    end
  end

  describe "Edit Site" do
    before do
      populate_collection_select_fields
      @site = create :site, name: 'Test Site', status: 'active', site_type_code: 'city'
      @site.contacts.create(address: '1 California Street', city: 'San Francisco', state: 'CA', zip: '94111')
      init_setup admin_user
      visit edit_site_path(@site)
    end

    it "edits a Site" do
      find("input[placeholder='Address']").set '1 Market Street'
      click_button 'Save Changes'
      sleep 5
      expect(@site.contacts.first.address).to eq '1 Market Street'
    end

    it "displays navbar" do
      test_navbar(false)
    end
  end
end
