require 'spec_helper'

describe TempListing do
  before(:each) do
    @temp_listing = FactoryGirl.create(:temp_listing) 
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
  it { should respond_to(:pixi_id) }
  it { should respond_to(:parent_pixi_id) }

  it { should respond_to(:user) }
  it { should respond_to(:site) }
  it { should respond_to(:transaction) }
  it { should respond_to(:pictures) }
  it { should respond_to(:category) }
  it { should respond_to(:set_flds) }
  it { should respond_to(:generate_token) }
  it { should respond_to(:site_listings) }

  describe "when price is not a number" do
    before { @temp_listing.price = "$500" }
    it { should_not be_valid }
  end
  
  describe "when price is less than 0" do
    before { @temp_listing.price = -500.00 }
    it { should_not be_valid }
  end
  
  describe "when price is greater than 1M" do
    before { @temp_listing.price = 5000000.00 }
    it { should_not be_valid }
  end
  
  describe "when price is greater than 0 but less than 1M" do
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

  describe "should not include invalid site listings" do 
    it { TempListing.get_by_site(0).should_not include @temp_listing } 
  end

  describe "should include site listings" do
    it { TempListing.get_by_site(@temp_listing.site.id).should_not be_empty }
  end

  describe "should include seller listings" do
    it { TempListing.get_by_seller(1).should_not be_empty }
  end

  describe "should not include incorrect seller listings" do 
    it { TempListing.get_by_seller(0).should_not include @temp_listing } 
  end

  describe "get_by_status should not include inactive listings" do
    temp_listing = FactoryGirl.create :listing, :description=>'stuff', :status=>'inactive'
    it { TempListing.get_by_status('active').should_not include (temp_listing) }
  end

  describe "should return correct site name" do 
    it { @temp_listing.site_name.should_not be_empty } 
  end

  describe "should not find correct site name" do 
    temp_listing = FactoryGirl.create :temp_listing, site_id: 100
    it { temp_listing.site_name.should be_nil } 
  end

  describe "should find correct category name" do 
    it { @temp_listing.category_name.should == 'Foo Bar' } 
  end

  describe "should not find correct category name" do 
    temp_listing = FactoryGirl.create :temp_listing, category_id: 100
    it { temp_listing.category_name.should be_nil } 
  end

  describe "should find correct seller name" do 
    let(:user) { FactoryGirl.create(:user) }
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id) }

    it { temp_listing.seller_name.should == "Joe Blow" } 
  end

  describe "should not find correct seller name" do 
    temp_listing = FactoryGirl.create :temp_listing, seller_id: 100
    it { temp_listing.seller_name.should be_nil } 
  end

  describe "should have a transaction" do 
    it { @temp_listing.has_transaction?.should be_true }
  end

  describe "should not have a transaction" do 
    temp_listing = FactoryGirl.create :temp_listing, transaction_id: nil
    it { temp_listing.has_transaction?.should_not be_true }
  end

  describe "should verify if seller name is an alias" do 
    temp_listing = FactoryGirl.create :temp_listing, show_alias_flg: 'yes'
    it { temp_listing.alias?.should be_true }
  end

  describe "should not have an alias" do 
    temp_listing = FactoryGirl.create :temp_listing, show_alias_flg: 'no'
    it { temp_listing.alias?.should_not be_true }
  end

  describe "seller" do 
    let(:temp_listing) { FactoryGirl.create :temp_listing, seller_id: 1 }

    it "should verify user is seller" do 
      temp_listing.seller?(1).should be_true 
    end

    it "should not verify user is seller" do 
      temp_listing.seller?(2).should_not be_true 
    end
  end

  describe "should return a short description" do 
    temp_listing = FactoryGirl.create :temp_listing, description: "a" * 100
    it { temp_listing.brief_descr.length.should == 30 }
  end

  describe "should not return a short description" do 
    temp_listing = FactoryGirl.create :temp_listing, description: 'qqq'
    it { temp_listing.brief_descr.length.should_not == 30 }
  end

  describe "should return a nice title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: 'guitar for sale'
    it { temp_listing.nice_title.should == 'Guitar For Sale' }
  end

  describe "should not return a nice title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: 'qqq'
    it { temp_listing.nice_title.should_not == 'Guitar For Sale' }
  end

  describe "should return a short title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: "a" * 40
    it { temp_listing.short_title.length.should == 18 }
  end

  describe "should not return a short title" do 
    temp_listing = FactoryGirl.build :temp_listing, title: 'qqq'
    it { temp_listing.short_title.length.should_not == 18 }
  end

  describe "set flds" do 
    let(:temp_listing) { FactoryGirl.create :temp_listing, status: "" }

    it "should call set flds" do 
      temp_listing.status.should == "new"
    end
  end

  describe "invalid set flds" do 
    let(:temp_listing) { FactoryGirl.build :temp_listing, title: nil, status: "" }
    
    it "should not call set flds" do 
      temp_listing.save
      temp_listing.status.should_not == 'new'
    end
  end 

  describe "should return site count > 0" do 
    temp_listing = FactoryGirl.create :temp_listing, site_id: 100
    it { temp_listing.get_site_count.should == 0 } 
  end

  describe "should not return site count > 0" do 
    it { @temp_listing.get_site_count.should_not == 0 } 
  end

  describe "transactions" do
    let(:transaction) { FactoryGirl.create :transaction }

    context "get_by_status should include new listings" do
      it { TempListing.get_by_status('active').should_not be_empty } 
    end

    it "should not submit order" do 
      @temp_listing.submit_order(nil).should_not be_true
    end

    it "should submit order" do 
      @temp_listing.submit_order(transaction.id).should be_true
    end

    it "should resubmit order" do 
      temp_listing = FactoryGirl.create :temp_listing, transaction_id: transaction.id
      temp_listing.resubmit_order.should be_true 
    end

    it "should not resubmit order" do 
      temp_listing = FactoryGirl.create :temp_listing, transaction_id: nil
      temp_listing.resubmit_order.should_not be_true
    end
  end

  describe "approved order" do
    let(:user) { FactoryGirl.create :user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "approve order should not return approved status" do 
      @temp_listing.approve_order(nil)
      @temp_listing.status.should_not == 'approved'
    end

    it "approve order should return approved status" do 
      temp_listing.approve_order(user)
      temp_listing.status.should == 'approved'
    end
  end

  describe "deny order" do
    let(:user) { FactoryGirl.create :user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "deny order should not return denied status" do 
      @temp_listing.deny_order(nil)
      @temp_listing.status.should_not == 'denied'
    end

    it "deny order should return denied status" do 
      temp_listing.deny_order(user)
      temp_listing.status.should == 'denied'
    end
  end

  describe "post to board" do
    let(:user) { FactoryGirl.create :user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "post to board should not return new listing" do 
      temp_listing.post_to_board.should_not be_true
    end

    it "post to board should return new listing" do 
      temp_listing.status = 'approved'
      temp_listing.post_to_board.should be_true
    end
  end

  describe "should verify new status" do 
    temp_listing = FactoryGirl.build :temp_listing, status: 'new'
    it { temp_listing.new_status?.should be_true }
  end

  describe "should not verify new status" do 
    temp_listing = FactoryGirl.build :temp_listing, status: 'pending'
    it { temp_listing.new_status?.should_not be_true }
  end

  describe "must have pictures" do
    let(:temp_listing) { FactoryGirl.build :invalid_temp_listing }

    it "should not save w/o at least one picture" do
      picture = temp_listing.pictures.build
      temp_listing.should_not be_valid
    end

    it "should save with at least one picture" do
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save
      temp_listing.should be_valid
    end
  end

  describe "delete photo" do
    let(:temp_listing) { FactoryGirl.create :temp_listing }

    it "should not delete photo" do 
      pic = temp_listing.pictures.first
      temp_listing.delete_photo(pic.id).should_not be_true
    end

    it "should delete photo" do 
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save
      pic = temp_listing.pictures.first
      temp_listing.delete_photo(pic.id).should be_true
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
