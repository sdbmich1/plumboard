require 'spec_helper'

describe Rating do
  before(:each) do
    @user = FactoryGirl.create :pixi_user
    @seller = FactoryGirl.create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tom.davis@pixitest.com'
    @listing = FactoryGirl.create :listing, seller_id: @user.id, title: 'Big Guitar'
    @rating = @user.ratings.build user_id: @user.id, seller_id: @seller.id
  end
   
  subject { @rating }

  it { should respond_to(:comments) }
  it { should respond_to(:user_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:seller_id) }
  it { should respond_to(:value) }

  it { should respond_to(:user) }
  it { should respond_to(:listing) }
  it { should respond_to(:seller) }

  describe "when comments is empty" do
    before { @rating.comments = "" }
    it { should_not be_valid }
  end

  describe "when comments is not empty" do
    it { should be_valid }
  end

  describe "when user_id is empty" do
    before { @rating.user_id = "" }
    it { should_not be_valid }
  end

  describe "when value is empty" do
    before { @rating.value = nil }
    it { should_not be_valid }
  end

end
