require 'spec_helper'

describe Listing do
  before(:each) do
    @listing = FactoryGirl.create(:listing) 
  end

  subject { @listing }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:site_id) }
  it { should respond_to(:seller_id) }
  it { should respond_to(:alias_name) }
  it { should respond_to(:transaction_id) }
  it { should respond_to(:show_alias_flg) }
  it { should respond_to(:status) }
  it { should respond_to(:price) }
  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:buyer_id) }
  it { should respond_to(:show_phone_flg) }
  it { should respond_to(:category_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:parent_pixi_id) }

  it { should respond_to(:user) }
  it { should respond_to(:site) }
  it { should respond_to(:posts) }
  it { should respond_to(:site_listings) }
  it { should respond_to(:transaction) }
  it { should respond_to(:pictures) }
  it { should respond_to(:category) }
  it { should respond_to(:set_flds) }
  it { should respond_to(:generate_token) }

  describe "when site_id is empty" do
    before { @listing.site_id = "" }
    it { should_not be_valid }
  end

  describe "when site_id is entered" do
    before { @listing.site_id = 1 }
    it { @listing.site_id.should == 1 }
  end

  describe "when price is not a number" do
    before { @listing.price = "$500" }
    it { should_not be_valid }
  end
  
  describe "when price is a number" do
    before { @listing.price = 50.00 }
    it { should be_valid }
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

  describe "when title is too large" do
    before { @listing.title = "a" * 81 }
    it { should_not be_valid }
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

  describe "should not include inactive listings" do
    listing = FactoryGirl.create :listing, :description=>'stuff', :status=>'inactive'
    it { Listing.active.should_not include (listing) }
  end

  describe "should include active listings" do 
    it { Listing.active.should == [@listing] } 
  end

  describe "get_by_status should not include inactive listings" do
    listing = FactoryGirl.create :listing, :description=>'stuff', :status=>'inactive'
    it { Listing.get_by_status('active').should_not include (listing) }
  end

  describe "get_by_status should include active listings" do 
    it { Listing.get_by_status('active').should == [@listing] } 
  end

  describe "should not include invalid site listings" do 
    it { Listing.get_by_site(0).should_not include @listing } 
  end

  describe "should include active site listings" do 
    it { Listing.get_by_site(@listing.site.id).should_not be_empty }
  end

  describe "should include seller listings" do 
    it { Listing.get_by_seller(1).should == [@listing] } 
  end

  describe "should not include incorrect seller listings" do 
    it { Listing.get_by_seller(0).should_not include @listing } 
  end

  describe "should return correct site name" do 
    it { @listing.site_name.should_not be_empty } 
  end

  describe "should not find correct site name" do 
    listing = FactoryGirl.create :listing, site_id: 100
    it { listing.site_name.should be_nil } 
  end

  describe "should find correct category name" do 
    it { @listing.category_name.should == 'Foo Bar' } 
  end

  describe "should not find correct category name" do 
    listing = FactoryGirl.create :listing, category_id: 100
    it { listing.category_name.should be_nil } 
  end

  describe "should find correct seller name" do 
    let(:user) { FactoryGirl.create(:user) }
    let(:listing) { FactoryGirl.create(:listing, seller_id: user.id) }

    it { listing.seller_name.should == "Joe Blow" } 
  end

  describe "should not find correct seller name" do 
    listing = FactoryGirl.create :listing, seller_id: 100
    it { listing.seller_name.should be_nil } 
  end

  describe "should have a transaction" do 
    it { @listing.has_transaction?.should be_true }
  end

  describe "should not have a transaction" do 
    listing = FactoryGirl.create :listing, transaction_id: nil
    it { listing.has_transaction?.should_not be_true }
  end

  describe "should verify if seller name is an alias" do 
    listing = FactoryGirl.create :listing, show_alias_flg: 'yes'
    it { listing.alias?.should be_true }
  end

  describe "should not have an alias" do 
    listing = FactoryGirl.create :listing, show_alias_flg: 'no'
    it { listing.alias?.should_not be_true }
  end

  describe "should verify user is seller" do 
    listing = FactoryGirl.create :listing, seller_id: 1
    it { listing.seller?(1).should be_true }
  end

  describe "should not verify user is seller" do 
    listing = FactoryGirl.create :listing, seller_id: 1
    it { listing.seller?(2).should_not be_true }
  end

  describe "should return a short description" do 
    listing = FactoryGirl.create :listing, description: "a" * 100
    it { listing.brief_descr.length.should == 30 }
  end

  describe "should not return a short description of 30 chars" do 
    listing = FactoryGirl.create :listing, description: "a"
    it { listing.brief_descr.length.should_not == 30 }
  end

  describe "set flds" do 
    let(:listing) { FactoryGirl.create :listing, status: "" }

    it "should call set flds" do 
      listing.status.should == "new"
    end
  end

  describe "invalid set flds" do 
    let(:listing) { FactoryGirl.build :listing, title: nil, status: "" }
    
    it "should not call set flds" do 
      listing.save
      listing.status.should_not == 'new'
    end
  end 

  describe "must have pictures" do 
    let(:listing) { FactoryGirl.build :invalid_listing }
    it "should not save w/o at least one picture" do 
      listing.save
      listing.should_not be_valid 
    end
  end 
    
  describe "should activate" do 
    let(:listing) { FactoryGirl.build :listing, start_date: Time.now, status: 'pending' }
    it { listing.activate.status.should == 'active' } 
  end

  describe "should not activate" do 
    let(:listing) { FactoryGirl.build :listing, start_date: Time.now, status: 'sold' }
    it { listing.activate.status.should_not == 'active' } 
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
