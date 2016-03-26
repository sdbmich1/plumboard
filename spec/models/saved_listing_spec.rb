require 'spec_helper'

describe SavedListing do
  before(:all) do
    @user = create(:pixi_user) 
    @category = create(:category, pixi_type: 'premium') 
    @listing = create(:listing, seller_id: @user.id) 
  end
  before(:each) do
    @saved_listing = @user.saved_listings.build attributes_for :saved_listing, pixi_id: @listing.pixi_id
  end

  subject { @saved_listing }

  it { is_expected.to respond_to(:pixi_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:listing) }
  it { is_expected.to respond_to(:set_flds) }

  it { is_expected.to validate_presence_of(:pixi_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to belong_to(:listing).with_foreign_key('pixi_id') }
  it { is_expected.to belong_to(:user) }

  describe 'set_flds' do
    it "sets status to active" do
      @saved_listing.save
      expect(@saved_listing.status).to eq('active')
    end

    it "does not set status to active" do
      @saved_listing.status = 'inactive'
      @saved_listing.save
      expect(@saved_listing.status).not_to eq('active')
    end
  end

  describe "get_by_status" do 
    it { expect(SavedListing.get_by_status('active')).to be_empty }
    it "includes active listings" do  
      @saved_listing.save
      expect(SavedListing.get_by_status('active')).not_to be_empty 
    end
  end

  describe 'active_by_pixi' do
    before :each, run: true do
      @saved_listing.status = 'wanted'
    end
    it 'shows active items' do
      @saved_listing.save
      expect(SavedListing.active_by_pixi(@listing.pixi_id).size).to eq 1
    end
    it 'does not show active items', run: true do
      @saved_listing.save
      expect(SavedListing.active_by_pixi(@listing.pixi_id).size).to eq 0
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
      expect(SavedListing.update_status_by_user(@saved_listing.user_id, @listing.pixi_id, 'wanted')).to be_truthy
    end

    it "does not update status" do
      expect(SavedListing.update_status_by_user(nil, @listing.pixi_id, 'wanted')).to be_nil
    end
  end
  describe "first name" do
    it { expect(@saved_listing.first_name).to eq(@user.first_name) }

    it "does not find user name" do
      @saved_listing.user_id = 100
      @saved_listing.save
      @saved_listing.reload
      expect(@saved_listing.first_name).to be_nil
    end
  end

end
