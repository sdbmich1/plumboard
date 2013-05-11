require 'spec_helper'

describe Listing do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id) 
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

  describe "inactive listings" do
    before(:each) do
      @listing.status = 'inactive' 
      @listing.save
    end

    it "should not include inactive listings" do
      Listing.active.should_not == @listing 
    end

    it "active page should not include inactive listings" do
      Listing.active_page(1).should_not == @listing 
    end

    it "get_by_status should not include inactive listings" do
      Listing.get_by_status('active').should_not == @listing 
    end
  end

  describe "should include active listings" do 
    it { Listing.active.should be_true }
  end

  describe "active page should include active listings" do 
    it { Listing.active_page(1).should be_true }
  end

  describe "get_by_status should include active listings" do 
    it { Listing.get_by_status('active').should_not be_empty }
  end

  describe "should not include invalid site listings" do 
    it { Listing.get_by_site(0).should_not include @listing } 
  end

  describe "should include active site listings" do 
    it { Listing.get_by_site(@listing.site.id).should_not be_empty }
  end

  it "should include seller listings" do 
    @listing.seller_id = 1
    @listing.save
    Listing.get_by_seller(1).should_not be_empty  
  end

  describe "should not include incorrect seller listings" do 
    it { Listing.get_by_seller(0).should_not include @listing } 
  end

  describe "should return correct site name" do 
    it { @listing.site_name.should_not be_empty } 
  end

  describe "incorrect site" do 
    before { @listing.site_id = 100 }

    it "should not find correct site name" do 
      @listing.site_name.should be_nil 
    end

    it "should not return site count > 0" do 
      @listing.get_site_count.should == 0  
    end
  end

  describe "should return site count > 0" do 
    it { @listing.get_site_count.should_not == 0 } 
  end

  describe "should find correct category name" do 
    it { @listing.category_name.should == 'Foo Bar' } 
  end

  describe "should not find correct category name" do 
    before { @listing.category_id = 100 }
    it { @listing.category_name.should be_nil } 
  end

  describe "should find correct seller name" do 
    it { @listing.seller_name.should == "Joe Blow" } 
  end

  describe "should not find correct seller name" do 
    before { @listing.seller_id = 100 }
    it { @listing.seller_name.should be_nil } 
  end

  describe "should have a transaction" do 
    it { @listing.has_transaction?.should be_true }
  end

  describe "should not have a transaction" do 
    before { @listing.transaction_id = nil }
    it { @listing.has_transaction?.should_not be_true }
  end

  it "should verify if seller name is an alias" do 
    @listing.show_alias_flg = 'yes'
    @listing.alias?.should be_true 
  end

  it "should not have an alias" do 
    @listing.show_alias_flg = 'no'
    @listing.alias?.should_not be_true 
  end

  describe "seller" do 
    before { @listing.seller_id = 1 }

    it "should verify user is seller" do 
      @listing.seller?(1).should be_true 
    end

    it  "should not verify user is seller" do 
      @listing.seller?(2).should_not be_true 
    end
  end

  describe "description" do 
    before { @listing.description = "a" * 100 }

    it "should return a short description" do 
      @listing.brief_descr.length.should == 100 
    end

    it "should return a summary" do 
      @listing.summary.should be_true 
    end
  end

  it "should not return a short description of 100 chars" do 
    @listing.description = "a" 
    @listing.brief_descr.length.should_not == 100 
  end

  it "should not return a summary" do 
    @listing.description = nil
    @listing.summary.should_not be_true 
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

  describe 'check for free order' do
    it "should not allow free order" do 
      (0..100).each do
        @listing = FactoryGirl.create(:listing, seller_id: @user.id, site_id: 100) 
      end
      Listing.free_order?(100).should_not be_true  
    end

    it "should allow free order" do 
      @listing.site_id = 2 
      Listing.free_order?(2).should be_true  
    end
  end  

  describe 'premium?' do
    it 'should return true' do
      @listing.category_id = @category.id 
      @listing.premium?.should be_true
    end

    it 'should not return true' do
      category = FactoryGirl.create(:category)
      @listing.category_id = category.id
      @listing.premium?.should_not be_true
    end
  end
end
