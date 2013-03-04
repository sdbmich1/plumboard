require 'spec_helper'

describe TempListing do
  before(:each) do
    @temp_listing = FactoryGirl.create(:listing) 
  end

  subject { @temp_listing }

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

  it { should respond_to(:user) }
  it { should respond_to(:site) }
  it { should respond_to(:transaction) }
  it { should respond_to(:pictures) }
  it { should respond_to(:category) }
  it { should respond_to(:set_flds) }

  describe "when price is not a number" do
    before { @temp_listing.price = "$500" }
    it { should_not be_valid }
  end
  
  describe "when price is a number" do
    before { @temp_listing.price = 500.00 }
    it { should be_valid }
  end
  
  describe "when site_id is empty" do
    before { @temp_listing.site_id = "" }
    it { should_not be_valid }
  end
  
  describe "when site_id is entered" do
    before { @temp_listing.site_id = 1 }
    it { @temp_listing.site_id.should == 1 }
  end

  describe "when seller_id is empty" do
    before { @temp_listing.seller_id = "" }
    it { should_not be_valid }
  end

  describe "when seller_id is entered" do
    before { @temp_listing.seller_id = 1 }
    it { @temp_listing.seller_id.should == 1 }
  end

  describe "when transaction_id is entered" do
    before { @temp_listing.transaction_id = 1 }
    it { @temp_listing.transaction_id.should == 1 }
  end

  describe "when start_date is empty" do
    before { @temp_listing.start_date = "" }
    it { should_not be_valid }
  end

  describe "when start_date is entered" do
    before { @temp_listing.start_date = Time.now }
    it { should be_valid }
  end

  describe "when title is empty" do
    before { @temp_listing.title = "" }
    it { should_not be_valid }
  end

  describe "when title is entered" do 
    before { @temp_listing.title = "chair" }
    it { @temp_listing.title.should == "chair" }
  end

  describe "when title is too large" do
    before { @temp_listing.title = "a" * 81 }
    it { should_not be_valid }
  end

  describe "when description is entered" do 
    before { @temp_listing.description = "chair" }
    it { @temp_listing.description.should == "chair" }
  end

  describe "when description is empty" do
    before { @temp_listing.description = "" }
    it { should_not be_valid }
  end

  describe "when category_id is entered" do 
    before { @temp_listing.category_id = 1 }
    it { @temp_listing.category_id.should == 1 }
  end

  describe "when category_id is empty" do
    before { @temp_listing.category_id = "" }
    it { should_not be_valid }
  end

  describe "should not include inactive listings" do
    temp_listing = FactoryGirl.create :listing, :description=>'stuff', :status=>'inactive'
    it { TempListing.active.should_not include (temp_listing) }
  end

  describe "should not include invalid site listings" do 
    it { TempListing.get_by_site(0).should_not include @temp_listing } 
  end

  describe "should include active site & seller listings" do 
    let(:temp_listing) { TempListing.new title: 'listing', description: 'test', site_id: 1, seller_id: 1, category_id: 1, start_date: Time.now }
    before(:each) do
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save!
    end

    it { TempListing.get_by_site(1).should_not be_empty }
    it { TempListing.get_by_seller(1).should_not be_empty }
  end

  describe "should not include incorrect seller listings" do 
    it { TempListing.get_by_seller(0).should_not include @temp_listing } 
  end

  describe "should return correct site name" do 
    temp_listing = FactoryGirl.create :listing
    it { temp_listing.site_name.should_not be_empty } 
  end

  describe "should not find correct site name" do 
    temp_listing = FactoryGirl.create :listing, site_id: 100
    it { temp_listing.site_name.should be_nil } 
  end

  describe "should find correct category name" do 
    it { @temp_listing.category_name.should == 'Foo Bar' } 
  end

  describe "should not find correct category name" do 
    temp_listing = FactoryGirl.create :listing, category_id: 100
    it { temp_listing.category_name.should be_nil } 
  end

  describe "should find correct seller name" do 
    let(:user) { FactoryGirl.create(:user) }
    let(:temp_listing) { FactoryGirl.create(:listing, seller_id: user.id) }

    it { temp_listing.seller_name.should == "Joe Blow" } 
  end

  describe "should not find correct seller name" do 
    temp_listing = FactoryGirl.create :listing, seller_id: 100
    it { temp_listing.seller_name.should be_nil } 
  end

  describe "should have a transaction" do 
    it { @temp_listing.has_transaction?.should be_true }
  end

  describe "should not have a transaction" do 
    temp_listing = FactoryGirl.create :listing, transaction_id: nil
    it { temp_listing.has_transaction?.should_not be_true }
  end

  describe "should verify if seller name is an alias" do 
    temp_listing = FactoryGirl.create :listing, show_alias_flg: 'yes'
    it { temp_listing.alias?.should be_true }
  end

  describe "should not have an alias" do 
    temp_listing = FactoryGirl.create :listing, show_alias_flg: 'no'
    it { temp_listing.alias?.should_not be_true }
  end

  describe "should verify user is seller" do 
    temp_listing = FactoryGirl.create :listing, seller_id: 1
    it { temp_listing.seller?(1).should be_true }
  end

  describe "should not verify user is seller" do 
    temp_listing = FactoryGirl.create :listing, seller_id: 1
    it { temp_listing.seller?(2).should_not be_true }
  end

  describe "should return a short description" do 
    temp_listing = FactoryGirl.create :listing, description: "a" * 100
    it { temp_listing.brief_descr.length.should == 30 }
  end

  describe "set flds" do 
    let(:temp_listing) { FactoryGirl.create :listing, status: "" }

    it "should call set flds" do 
      temp_listing.status.should == "pending"
    end
  end

  describe "invalid set flds" do 
    let(:temp_listing) { FactoryGirl.build :listing, title: nil, status: "" }
    
    it "should not call set flds" do 
      temp_listing.save
      temp_listing.status.should_not == 'pending'
    end
  end 

  describe "should activate" do 
    temp_listing = FactoryGirl.build :listing, start_date: Time.now, status: 'pending' 
    it { temp_listing.activate.status.should == 'active' } 
  end

  describe "should not activate" do 
    let(:temp_listing) { FactoryGirl.build :listing, start_date: Time.now, status: 'sold' } 
    it { temp_listing.activate.status.should_not == 'active' } 
  end

  describe "must have pictures" do
    let(:temp_listing) { TempListing.new title: 'listing', description: 'test', site_id: 1, seller_id: 1, category_id: 1, start_date: Time.now }
    it "should not save w/o at least one picture" do
      temp_listing.save
      temp_listing.should_not be_valid
    end
  end

  describe 'pictures' do
    before(:each) do
      @sr = @temp_listing.pictures.create FactoryGirl.attributes_for(:picture)
    end
				            
    it "should have many pictures" do 
      @temp_listing.pictures.should include(@sr)
    end

    it "should destroy associated pictures" do
      @temp_listing.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
     end  
   end  
end
