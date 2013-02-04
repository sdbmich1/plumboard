require 'spec_helper'

describe Picture do
  before(:each) do
    @file = "/spec/fixtures/photo.jpg"
    @listing = FactoryGirl.create(:listing)
    @organization = FactoryGirl.create(:organization)
    @picture = @listing.pictures.build(:photo_file_name => @file)
    @org_picture = @organization.pictures.build(:photo_file_name => @file)
  end

  describe "listing photo validations" do
    it "should be valid" do
      @picture.should be_valid
    end

    it "should create a new instance given valid attributes" do
      @picture.save!
    end
  end

  context "check presenter photo attributes" do
    before(:each) do
      @picture.save!
    end

    it "should receive photo_file_name from :photo" do 
      @picture.photo_file_name.should == @file
    end
  end

end
