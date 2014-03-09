require 'spec_helper'

describe Picture do
  before(:each) do
    filename = "#{Rails.root}/spec/fixtures/photo.jpg"
    filename2 = "#{Rails.root}/spec/fixtures/photo2.png"

    @file = Rack::Test::UploadedFile.new(filename, "image/jpg")
    @bigfile = Rack::Test::UploadedFile.new(filename2, "image/png")

    @listing = FactoryGirl.create(:listing)
    @site = FactoryGirl.create(:site)

    @bigpic = @listing.pictures.build
    @picture = @listing.pictures.build
    @site_picture = @site.pictures.build
    @picture.photo, @bigpic.photo, @site_picture.photo  = @file, @bigfile, @file
  end

  subject { @picture } 

  it { should respond_to(:photo) }
  it { should respond_to(:photo_file_name) }
  it { should respond_to(:photo_content_type) }
  it { should respond_to(:photo_file_size) }
  it { should respond_to(:photo_updated_at) }
  it { should respond_to(:set_default_url) }

  it { should respond_to(:imageable) }
  it { should have_attached_file(:photo) }
  it { should validate_attachment_content_type(:photo).
                      allowing('image/png', 'image/gif', 'image/jpg', 'image/jpeg', 'image/bmp').
                      rejecting('text/plain', 'text/xml') }
  it { should validate_attachment_size(:photo).less_than(5.megabytes) }

  describe "listing photo validations" do
    it "big pic should not be valid" do
      @bigpic.should_not be_valid
    end

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
      @picture.photo_file_name.should_not be_empty
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
      @site_picture.photo_file_name.should_not be_empty
    end
  end

  describe "regenerate_styles" do
    it { @picture.should respond_to :regenerate_styles }
  end
end
