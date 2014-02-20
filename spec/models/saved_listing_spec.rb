require 'spec_helper'

describe SavedListing do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
    @saved_listing = @user.saved_listings.build FactoryGirl.attributes_for :saved_listing, pixi_id: @listing.pixi_id
  end

  subject { @saved_listing }

  it { should respond_to(:pixi_id) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:listing) }

  it { should validate_presence_of(:pixi_id) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:pixi_id) }
  it { should belong_to(:listing).with_foreign_key('pixi_id') }
  it { should belong_to(:user) }
end
