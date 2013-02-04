require 'spec_helper'

describe Interest do
  before(:each) do
    @interest = FactoryGirl.build(:interest) 
  end

  it "should have an users method" do
    @interest.should respond_to(:users)
  end

  it "should have an user_interests method" do
    @interest.should respond_to(:user_interests)
  end

  describe "when name is empty" do
    before { @interest.name = "" }
    it { should_not be_valid }
  end

  describe "should include active interests" do
    interest = Interest.create(:name=>'Item', :status=>'active')
    it { Interest.active.should include (interest) } 
  end

  describe "when interest is inactive" do
    interest = Interest.create(:name=>'Item', :status=>'inactive')
    it { Interest.active.should_not include (interest) }  
  end

end
