require 'spec_helper'

describe Picture do
  before(:each) do
    @file = "/spec/fixtures/photo.jpg"
    @listing = FactoryGirl.create(:listing)
    @site = FactoryGirl.create(:site)
    @picture = @listing.pictures.build(:photo_file_name => @file)
    @site_picture = @site.pictures.build(:photo_file_name => @file)
  end

  subject { @picture } 

  it { should respond_to(:photo) }
  it { should respond_to(:photo_file_name) }
  it { should respond_to(:photo_content_type) }
  it { should respond_to(:photo_file_size) }
  it { should respond_to(:photo_updated_at) }
  it { should respond_to(:delete_photo) }
  it { should respond_to(:set_default_url) }

  it { should respond_to(:imageable) }
  it { should have_attached_file(:photo) }
  it { should validate_attachment_content_type(:photo).
                      allowing('image/png', 'image/gif', 'image/jpg', 'image/jpeg', 'image/bmp').
                      rejecting('text/plain', 'text/xml') }
  it { should validate_attachment_size(:photo).less_than(1.megabytes) }

  describe "delete photo" do
    let(:listing) { FactoryGirl.build :listing }
    let(:picture) { listing.pictures.build FactoryGirl.attributes_for(:picture) }

    it "should remove photo when validated" do
      picture.delete_photo = '1'
      picture.valid?
      picture.photo.should_not == "/spec/fixtures/photo.jpg"	
    end

    it "should not remove photo when validated" do
      picture.delete_photo = '0'
      picture.valid?
      picture.photo.should_not be_nil
    end
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
