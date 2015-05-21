require 'spec_helper'

feature "Searches" do
  subject { page }

  let(:user) { create(:contact_user) }
  let(:category) { create :category }
  let(:site) { create :site }
  let(:condition_type) { create :condition_type, code: 'UG', description: 'Used - Good', hide: 'no', status: 'active' }
  let(:seller) {  create(:contact_user, user_type_code: 'BUS', business_name: 'Rhythm Music', description: 'The best music lives here.') }
  let(:listing) { create(:listing, title: "Blue Guitar", description: "Lessons", seller_id: seller.id, 
    site_id: site.id, quantity: 1, condition_type_code: condition_type.code, status: 'active') }

  def add_pixis model
    create(:listing, title: "Acoustic Guitar", seller_id: model.id, site_id: site.id, category_id: category.id, quantity: 1, 
      condition_type_code: condition_type.code)  
    create(:listing, title: "Bass Guitar", seller_id: model.id, site_id: site.id, category_id: category.id, quantity: 1, 
      condition_type_code: condition_type.code)  
  end

  describe 'biz' do
    before(:each) do
      add_pixis seller
      init_setup user
    end

    it 'renders seller page for user' do
      visit '/biz/rhythmmusic'
      page.should have_content seller.name
      page.should have_content seller.description
      page.should have_selector('#follow-btn', visible: true)
      expect(Listing.count).not_to eq 0
      # page.should have_content 'Acoustic Guitar'
      # page.should have_content 'Bass Guitar'
    end

    it "can follow and unfollow a business" do
      visit '/biz/rhythmmusic'
      page.should have_selector('#follow-btn', visible: true)
      find('#follow-btn').click
      page.should have_selector('#unfollow-btn', visible: true)
      find('#unfollow-btn').click
      page.should have_selector('#follow-btn', visible: true)
    end
  end

  describe 'mbr' do
  end
end

