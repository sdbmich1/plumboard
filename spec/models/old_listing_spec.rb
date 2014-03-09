require 'spec_helper'

describe OldListing do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.build(:old_listing, seller_id: @user.id) 
  end

  subject { @listing }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:site_id) }
  it { should respond_to(:seller_id) }
  it { should respond_to(:alias_name) }
  it { should respond_to(:transaction_id) }
  it { should respond_to(:show_alias_flg) }
  it { should respond_to(:status) }
  it { should respond_to(:price) }
  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:buyer_id) }
  it { should respond_to(:show_phone_flg) }
  it { should respond_to(:category_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:parent_pixi_id) }
  it { should respond_to(:post_ip) }
  it { should respond_to(:event_start_date) }
  it { should respond_to(:event_end_date) }
  it { should respond_to(:compensation) }
  it { should respond_to(:lng) }
  it { should respond_to(:lat) }
  it { should respond_to(:event_start_time) }
  it { should respond_to(:event_end_time) }
  it { should respond_to(:year_built) }
  it { should respond_to(:pixan_id) }
  it { should respond_to(:job_type) }
  it { should respond_to(:explanation) }

  it { should respond_to(:user) }
  it { should respond_to(:pictures) }

  describe "seller rating count" do 
    it { @listing.seller_rating_count.should == 0 } 

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
      listing.updated_dt.should be_nil
    end

    it { listing.updated_dt.should_not be_nil }
  end
end
