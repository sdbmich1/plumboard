require 'spec_helper'

shared_examples 'seller_url_pages' do |follow_flg, map_flg|
  describe 'view urls' do
    it 'renders seller page for user' do
      visit seller.local_user_path
      page.should have_content seller.name
      page.should have_content seller.description
      page.should have_selector('#follow-btn', visible: follow_flg)
      page.should have_selector('#map_icon', visible: map_flg)
      expect(Listing.count).not_to eq 0
      # page.should have_content 'Acoustic Guitar'
      # page.should have_content 'Bass Guitar'
    end
  end
end	
