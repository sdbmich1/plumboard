require 'spec_helper'

feature "Repost Listings" do
 subject { page }
  
 let(:user) { create(:contact_user) }
 let(:pixter) { create :pixter, user_type_code: 'PT', confirmed_at: Time.now }
 let(:admin) { create :admin, confirmed_at: Time.now }
 let(:category) { create :category }
 let(:site) { create :site, name: 'Detroit', site_type_code: 'city' }
 let(:contact) { site.contacts.create attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI', zip: '48227'}
 let(:condition_type) { create :condition_type, code: 'UG', description: 'Used - Good', hide: 'no', status: 'active' }

 before(:each) do
   add_region
 end

 describe "User Repost" do
   before { init_setup user }
   %w(sold expired removed).each do |val|
     it_should_behave_like 'repost_pixi_pages', val, false
   end
 end

 describe "Admin Repost" do
   before { init_setup admin }
   %w(sold expired removed).each do |val|
     it_should_behave_like 'repost_pixi_pages', val, true
   end
 end
end
