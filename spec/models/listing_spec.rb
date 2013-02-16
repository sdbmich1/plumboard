require 'spec_helper'

describe Listing do
  before(:each) do
    @listing = FactoryGirl.create(:listing) 
  end

  subject { @listing }

  it { should respond_to(:user) }
  it { should respond_to(:site) }
  it { should respond_to(:posts) }
  it { should respond_to(:site_listings) }
  it { should respond_to(:transaction) }
  it { should respond_to(:pictures) }
  it { should respond_to(:listing_categories) }
  it { should respond_to(:set_flds) }

  describe "when site_id is empty" do
    before { @listing.site_id = "" }
    it { should_not be_valid }
  end

  describe "when site_id is entered" do
    before { @listing.site_id = 1 }
    it { @listing.site_id.should == 1 }
  end

  describe "when seller_id is empty" do
    before { @listing.seller_id = "" }
    it { should_not be_valid }
  end

  describe "when seller_id is entered" do
    before { @listing.seller_id = 1 }
    it { @listing.seller_id.should == 1 }
  end

  describe "when transaction_id is entered" do
    before { @listing.transaction_id = 1 }
    it { @listing.transaction_id.should == 1 }
  end

  describe "when start_date is empty" do
    before { @listing.start_date = "" }
    it { should_not be_valid }
  end

  describe "when start_date is entered" do
    before { @listing.start_date = Time.now }
    it { should be_valid }
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

  describe "when category_id is entered" do 
    before { @listing.category_id = 1 }
    it { @listing.category_id.should == 1 }
  end

  describe "when category_id is empty" do
    before { @listing.category_id = "" }
    it { should_not be_valid }
  end

  describe "should include active listings" do 
    it { Listing.active.should == [@listing] } 
  end

  describe "should not include inactive listings" do
    listing = Listing.create(:title=>'Item', :description=>'stuff', :status=>'inactive')
    it { Listing.active.should_not include (listing) }
  end

  describe "should include active site listings" do 
    it { Listing.get_by_site(1).should == [@listing] } 
  end

  describe "should not include invalid site listings" do 
    it { Listing.get_by_site(0).should_not include @listing } 
  end

  describe "should include seller listings" do 
    it { Listing.get_by_seller(1).should == [@listing] } 
  end

  describe "should not include incorrect seller listings" do 
    it { Listing.get_by_seller(0).should_not include @listing } 
  end

  describe "set flds" do 
    it "should call set flds" do 
      listing = FactoryGirl.build :listing 
      listing.status = nil
      listing.save
      listing.status.should == 'active'
    end
    
    it "should not call set flds" do 
      listing = FactoryGirl.build :listing 
      listing.status = listing.title = nil
      listing.save
      listing.status.should_not == 'active'
    end
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
