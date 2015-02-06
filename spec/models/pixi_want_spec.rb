require 'spec_helper'

describe PixiWant do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
    @pixi_want = @user.pixi_wants.build FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
  end

  subject { @pixi_want }

  it { should respond_to(:pixi_id) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:listing) }
  it { should validate_presence_of(:pixi_id) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:pixi_id) }
  it { should belong_to(:listing).with_foreign_key('pixi_id') }
  it { should belong_to(:user) }

  describe "user name" do 
    it { @pixi_want.user_name.should == @user.name } 

    it "does not find user name" do 
      @pixi_want.user_id = 100
      @pixi_want.user_name.should be_nil  
    end
  end
end