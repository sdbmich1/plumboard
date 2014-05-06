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
  it { should respond_to(:status) }
  it { should respond_to(:user) }
  it { should respond_to(:listing) }
  it { should respond_to(:set_flds) }

  it { should validate_presence_of(:pixi_id) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:pixi_id) }
  it { should belong_to(:listing).with_foreign_key('pixi_id') }
  it { should belong_to(:user) }

  describe 'set_flds' do
    it "sets status to active" do
      @saved_listing.save
      @saved_listing.status.should == 'active'
    end

    it "does not set status to active" do
      @saved_listing.status = 'inactive'
      @saved_listing.save
      @saved_listing.status.should_not == 'active'
    end
  end

  describe "get_by_status" do 
    it { SavedListing.get_by_status('active').should be_empty }
    it "includes active listings" do  
      @saved_listing.save
      SavedListing.get_by_status('active').should_not be_empty 
    end
  end

  describe 'update status' do
    before :each do
      @listing.status = 'closed'
    end

    it "updates status" do
      @saved_listing.save
      expect(SavedListing.update_status(@listing.pixi_id, 'closed')).not_to eq(0)
    end

    it "does not update status" do
      @listing.save
      expect(SavedListing.update_status(@listing.pixi_id, 'closed')).to eq(0)
    end
  end

  describe 'update status by user' do
    it "updates status" do
      @saved_listing.save
      expect(SavedListing.update_status_by_user(@saved_listing.user_id, @listing.pixi_id, 'wanted')).to be_true
    end

    it "does not update status" do
      expect(SavedListing.update_status_by_user(nil, @listing.pixi_id, 'wanted')).to be_nil
    end
  end
  describe "first name" do
    it { @saved_listing.first_name.should == @user.first_name }

    it "does not find user name" do
      @saved_listing.user_id = 100
      @saved_listing.first_name.should be_nil
    end
  end

end
