require 'spec_helper'

feature "Urls" do
  subject { page }

  let(:user) { create(:contact_user) }
  let(:user2) { create(:contact_user) }
  let(:bus_user) { create(:business_user) }
  let(:category) { create :category }
  let(:site) { create :site }
  let(:condition_type) { create :condition_type, code: 'UG', description: 'Used - Good', hide: 'no', status: 'active' }
  let(:seller) {  create(:contact_user, user_type_code: 'BUS', business_name: 'Rhythm Music', description: 'The best music lives here.') }
  let(:listing) { create(:listing, title: "Blue Guitar", description: "Lessons", seller_id: seller.id, 
    site_id: site.id, quantity: 1, condition_type_code: condition_type.code, status: 'active') }

  def add_pixis model, loc=site
    create(:listing, title: "Acoustic Guitar", seller_id: model.id, site_id: loc.id, category_id: category.id, quantity: 1, 
      condition_type_code: condition_type.code)  
    create(:listing, title: "Bass Guitar", seller_id: model.id, site_id: loc.id, category_id: category.id, quantity: 1, 
      condition_type_code: condition_type.code)  
  end

  describe 'biz w/o address', base: true do
    before(:each) do
      add_pixis seller
      init_setup user
    end
    
    it_should_behave_like 'seller_url_pages', true, false

    it "can follow and unfollow a business" do
      visit '/biz/rhythmmusic'
      page.should have_selector('#follow-btn', visible: true)
      find('#follow-btn').click
      visit '/biz/rhythmmusic'
      page.should have_selector('#unfollow-btn', visible: true)
      find('#unfollow-btn').click
      visit '/biz/rhythmmusic'
      page.should have_selector('#follow-btn', visible: true)
    end
  end

  describe 'biz w/ address', address: true do
    before(:each) do
      add_pixis bus_user
      init_setup user
    end
    it_should_behave_like 'seller_url_pages', true, true
  end

  describe 'mbr' do
    before(:each) do
      add_pixis user2
      init_setup user
    end
    it_should_behave_like 'seller_url_pages', false, false
  end

  describe "site url pages", site: true do
    it_should_behave_like 'site_url_pages', 'Seattle', 'loc', 'city'
    it_should_behave_like 'site_url_pages', 'Seattle College', 'edu', 'school'
    it_should_behave_like 'site_url_pages', 'Seattle Times - Press', 'pub', 'pub'
  end

  describe "Non-signed in user" do
    before(:each) do
      add_pixis seller
    end
     
    it "does not follow a seller" do
      expect{
        visit '/biz/rhythmmusic'
        page.should have_selector('#follow-btn', visible: true)
        find('#follow-btn').click
      }.not_to change(FavoriteSeller,:count).by(1)
      # page.should have_content 'Sign in'
    end
  end
end

