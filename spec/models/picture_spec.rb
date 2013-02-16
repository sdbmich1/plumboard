require 'spec_helper'

describe Picture do
  before(:each) do
    @file = "/spec/fixtures/photo.jpg"
    @listing = FactoryGirl.create(:listing)
    @site = FactoryGirl.create(:site)
    @picture = @listing.pictures.build(:photo_file_name => @file)
    @site_picture = @site.pictures.build(:photo_file_name => @file)
  end

  describe "listing photo validations" do
    it "should be valid" do
      @picture.should be_valid
    end

    it "should create a new instance given valid attributes" do
      @picture.save!
    end
  end

  context "check listing photo attributes" do
    before(:each) do
      @picture.save!
    end

    it "should receive photo_file_name from :photo" do 
      @picture.photo_file_name.should == @file
    end
  end

  describe "site photo validations" do
    it "should be valid" do
      @site_picture.should be_valid
    end

    it "should create a new instance given valid attributes" do
      @site_picture.save!
    end
  end

  context "check site photo attributes" do
    before(:each) do
      @site_picture.save!
    end

    it "should receive photo_file_name from :photo" do 
      @site_picture.photo_file_name.should == @file
    end
  end

end
