require 'spec_helper'

describe OldListing do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.build(:old_listing, seller_id: @user.id) 
  end

  subject { @listing }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:site_id) }
  it { is_expected.to respond_to(:seller_id) }
  it { is_expected.to respond_to(:alias_name) }
  it { is_expected.to respond_to(:transaction_id) }
  it { is_expected.to respond_to(:show_alias_flg) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:price) }
  it { is_expected.to respond_to(:start_date) }
  it { is_expected.to respond_to(:end_date) }
  it { is_expected.to respond_to(:buyer_id) }
  it { is_expected.to respond_to(:show_phone_flg) }
  it { is_expected.to respond_to(:category_id) }
  it { is_expected.to respond_to(:pixi_id) }
  it { is_expected.to respond_to(:parent_pixi_id) }
  it { is_expected.to respond_to(:post_ip) }
  it { is_expected.to respond_to(:event_start_date) }
  it { is_expected.to respond_to(:event_end_date) }
  it { is_expected.to respond_to(:compensation) }
  it { is_expected.to respond_to(:lng) }
  it { is_expected.to respond_to(:lat) }
  it { is_expected.to respond_to(:event_start_time) }
  it { is_expected.to respond_to(:event_end_time) }
  it { is_expected.to respond_to(:year_built) }
  it { is_expected.to respond_to(:pixan_id) }
  it { is_expected.to respond_to(:job_type) }
  it { is_expected.to respond_to(:explanation) }

  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:pictures) }

  describe "seller name" do 
    it { expect(@listing.seller_name).to eq(@user.name) } 

    it "does not find seller name" do 
      @listing.seller_id = 100 
      expect(@listing.seller_name).not_to eq(@user.name)
    end
  end

  describe "seller email" do 
    it { expect(@listing.seller_email).to eq(@user.email) } 

    it "does not find seller email" do 
      @listing.seller_id = 100 
      expect(@listing.seller_email).not_to eq(@user.email)
    end
  end

  describe "seller rating count" do 
    it { expect(@listing.seller_rating_count).to eq(0) } 

    it 'returns seller rating count' do 
      listing = create(:listing, seller_id: @user.id) 
      @buyer = create(:pixi_user, email: 'jsnow@ptest.com')
      @rating = @buyer.ratings.create FactoryGirl.attributes_for :rating, seller_id: @user.id, pixi_id: listing.id
      expect(@listing.seller_rating_count).to eq(1)
    end
  end

  describe "date display methods" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :old_listing, seller_id: user.id }

    it "does not show updated date" do
      listing.updated_at = nil
      expect(listing.updated_dt).to be_nil
    end

    it { expect(listing.updated_dt).not_to be_nil }
  end
end
