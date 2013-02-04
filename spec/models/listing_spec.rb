require 'spec_helper'

describe Listing do
  before(:each) do
    @listing = FactoryGirl.create(:listing) 
  end

  it "should have an user method" do
    @listing.should respond_to(:user)
  end

  it "should have an organization method" do
    @listing.should respond_to(:organization) 
  end

  it "should have a posts method" do
    @listing.should respond_to(:posts) 
  end

  it "should have an org_listings method" do
    @listing.should respond_to(:org_listings)
  end

  it "should have a transactions method" do
    @listing.should respond_to(:transaction) 
  end

  it "should have a pictures method" do
    @listing.should respond_to(:pictures) 
  end

  it "should have an listing_categories method" do
    @listing.should respond_to(:listing_categories)
  end

  describe "when org_id is empty" do
    before { @listing.org_id = "" }
    it { should_not be_valid }
  end

  describe "when org_id is entered" do
    before { @listing.org_id = 1 }
    it { @listing.org_id.should == 1 }
  end

  describe "when seller_id is empty" do
    before { @listing.seller_id = "" }
    it { should_not be_valid }
  end

  describe "when seller_id is entered" do
    before { @listing.seller_id = 1 }
    it { @listing.seller_id.should == 1 }
  end

  describe "when transaction_id is empty" do
    before { @listing.transaction_id = "" }
    it { should_not be_valid }
  end

  describe "when transaction_id is entered" do
    before { @listing.transaction_id = 1 }
    it { @listing.transaction_id.should == 1 }
  end

  describe "when start_date is empty" do
    before { @listing.start_date = "" }
    it { should_not be_valid }
  end

  describe "when end_date is empty" do
    before { @listing.end_date = "" }
    it { should_not be_valid }
  end

  describe "when title is empty" do
    before { @listing.title = "" }
    it { should_not be_valid }
  end

  describe "when title is entered" do
    before { @listing.title = "chair" }
    it { @listing.title.should == "chair" }
  end

  describe "when description is entered" do 
    before { @listing.description = "chair" }
    it { @listing.description.should == "chair" }
  end

  describe "when description is empty" do
    before { @listing.description = "" }
    it { should_not be_valid }
  end

  describe "should include active listings" do 
    it { Listing.active.should == [@listing] } 
  end

  describe "should not include inactive listings" do
    listing = Listing.create(:title=>'Item', :description=>'stuff', :status=>'inactive')
    it { Listing.active.should_not include (listing) }
  end

  describe 'pictures' do
    before(:each) do
      @sr = @listing.pictures.create FactoryGirl.attributes_for(:picture)
    end
				            
    it "should have many pictures" do 
      @listing.pictures.should include(@sr)
    end

    it "should destroy associated pictures" do
      @listing.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
     end  
   end  
end
