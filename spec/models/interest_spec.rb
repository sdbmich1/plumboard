require 'spec_helper'

describe Interest do
  before(:each) do
    @interest = FactoryGirl.build(:interest) 
  end

  subject { @interest }

  context "should have an users method" do
    it { is_expected.to respond_to(:users) }
  end

  context "should have an user_interests method" do
    it { is_expected.to respond_to(:user_interests) }
  end

  describe "should include active interests" do
    it { expect(Interest.active).not_to be_nil }
  end

  describe "when name is empty" do 
    before { @interest.name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when interest is inactive" do
    interest = Interest.create(:name=>'Item', :status=>'inactive')
    it { expect(Interest.active).not_to include (interest) }  
  end

end
