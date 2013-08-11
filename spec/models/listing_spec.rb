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
  it { should respond_to(:post_ip) }
  it { should respond_to(:event_start_date) }
  it { should respond_to(:event_end_date) }
  it { should respond_to(:compensation) }
  it { should respond_to(:lng) }
  it { should respond_to(:lat) }
  it { should respond_to(:event_start_time) }
  it { should respond_to(:event_end_time) }
  it { should respond_to(:year_built) }

  it { should respond_to(:user) }
  it { should respond_to(:site) }
  it { should respond_to(:posts) }
  it { should respond_to(:invoices) }
  it { should respond_to(:site_listings) }
  it { should respond_to(:transaction) }
  it { should respond_to(:pictures) }
  it { should respond_to(:category) }
  it { should respond_to(:comments) }

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

  describe "includes active listings" do 
    it { Listing.active.should be_true }
  end

  describe "active page includes active listings" do 
    it { Listing.active_page(1).should be_true }
  end

  describe "get_by_status includes active listings" do 
    it { Listing.get_by_status('active').should_not be_empty }
  end

  describe "does not include invalid site listings" do 
    it { Listing.get_by_site(0).should_not include @listing } 
  end

  describe "includes active site listings" do 
    it { Listing.get_by_site(@listing.site.id).should_not be_empty }
  end

  describe "does not include invalid category listings" do 
    it { Listing.get_by_category(0, 1).should_not include @listing } 
  end

  describe "includes active category listings" do 
    it { Listing.get_by_category(@listing.category_id, 1).should_not be_empty }
  end

  describe "category_by_site" do
    it { Listing.get_category_by_site(0, 1, 1).should_not include @listing } 
    it { Listing.get_category_by_site(@listing.category_id, @listing.site_id, 1).should_not be_empty }
  end

  it "includes seller listings" do 
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
    before do
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
    end

    it "should verify user is seller" do 
      @listing.seller?(@user).should be_true 
    end

    it  "should not verify user is seller" do 
      @listing.seller?(@user2).should_not be_true 
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

  describe 'get invoice' do
    before do 
      @buyer = FactoryGirl.create(:pixi_user)
      @invoice = @user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id) 
    end

    it 'should return true' do
      @listing.get_invoice(@invoice.id).should be_true
    end

    it 'should not return true' do
      @listing.get_invoice(0).should_not be_true
    end
  end

  describe 'sold?' do
    it 'should return true' do
      @listing.status = 'sold'
      @listing.sold?.should be_true
    end

    it 'should not return true' do
      @listing.sold?.should_not be_true
    end
  end

  describe 'mark_as_sold' do
    it 'should return true' do
      @listing.mark_as_sold.should be_true
    end

    it 'should not return true' do
      @listing.status = 'sold'
      @listing.mark_as_sold.should_not be_true
    end
  end

  describe "comment associations" do

    let!(:older_comment) do 
      FactoryGirl.create(:comment, listing: @listing, user_id: @user.id, created_at: 1.day.ago)
    end

    let!(:newer_comment) do
      FactoryGirl.create(:comment, listing: @listing, user_id: @user.id, created_at: 1.hour.ago)
    end

    it "should have the right comments in the right order" do
      @listing.comments.should == [newer_comment, older_comment]
    end

    it "should destroy associated comments" do
      comments = @listing.comments.dup
      @listing.destroy
      comments.should_not be_empty

      comments.each do |comment|
        Comment.find_by_id(comment.id).should be_nil
      end
    end
  end

  describe '.same_day?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Events', pixi_type: 'premium') 
      @listing.category_id = @cat.id
    end

    it "should respond to same_day? method" do
      @listing.should respond_to(:same_day?)
    end

    it "should be the same day" do
      @listing.event_start_date = Date.today
      @listing.event_end_date = Date.today
      @listing.same_day?.should be_true
    end

    it "should not be the same day" do
      @listing.event_start_date = Date.today
      @listing.event_end_date = Date.today+1.day
      @listing.same_day?.should be_false 
    end
  end

  describe '.event?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Event', pixi_type: 'premium') 
    end

    it "is not an event" do
      @listing.event?.should be_false 
    end

    it "is an event" do
      @listing.category_id = @cat.id
      @listing.event?.should be_true 
    end
  end

  describe '.has_year?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Automotive', pixi_type: 'premium') 
    end

    it "does not have a year" do
      @listing.has_year?.should be_false 
    end

    it "has a year" do
      @listing.category_id = @cat.id
      @listing.has_year?.should be_true 
    end
  end

  describe '.job?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') 
    end

    it "is not a job" do
      @listing.job?.should be_false 
    end

    it "is a job" do
      @listing.category_id = @cat.id
      @listing.job?.should be_true 
    end
  end

  describe '.start_date?' do
    it "has no start date" do
      @listing.start_date?.should be_false
    end

    it "has a start date" do
      @listing.event_start_date = Time.now
      @listing.start_date?.should be_true
    end
  end

  describe "date validations" do
    before do
      @cat = FactoryGirl.create(:category, name: 'Event', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      @listing.event_end_date = Date.today+3.days 
      @listing.event_start_time = Time.now+2.hours
      @listing.event_end_time = Time.now+3.hours
    end

    describe 'start date' do
      it "has valid start date" do
        @listing.event_start_date = Date.today+2.days
        @listing.should be_valid
      end

      it "should reject a bad start date" do
        @listing.event_start_date = Date.today-2.days
        @listing.should_not be_valid
      end

      it "should not be valid without a start date" do
        @listing.event_start_date = nil
        @listing.should_not be_valid
      end
    end

    describe 'end date' do
      before do
        @listing.event_start_date = Date.today+2.days 
        @listing.event_start_time = Time.now+2.hours
        @listing.event_end_time = Time.now+3.hours
      end

      it "has valid end date" do
        @listing.event_end_date = Date.today+3.days
        @listing.should be_valid
      end

      it "should reject a bad end date" do
        @listing.event_end_date = ''
        @listing.should_not be_valid
      end

      it "should reject end date < start date" do
        @listing.event_end_date = Date.today-2.days
        @listing.should_not be_valid
      end

      it "should not be valid without a end date" do
        @listing.event_end_date = nil
        @listing.should_not be_valid
      end
    end

    describe 'start time' do
      before do
        @listing.event_start_date = Date.today+2.days 
        @listing.event_end_date = Date.today+3.days 
        @listing.event_end_time = Time.now+3.hours
      end

      it "has valid start time" do
        @listing.event_start_time = Time.now+2.hours
        @listing.should be_valid
      end

      it "should reject a bad start time" do
        @listing.event_start_time = ''
        @listing.should_not be_valid
      end

      it "should not be valid without a start time" do
        @listing.event_start_time = nil
        @listing.should_not be_valid
      end
    end

    describe 'end time' do
      before do
        @listing.event_start_date = Date.today+2.days 
        @listing.event_end_date = Date.today+3.days 
        @listing.event_start_time = Time.now+2.hours
      end

      it "has valid end time" do
        @listing.event_end_time = Time.now+3.hours
        @listing.should be_valid
      end

      it "should reject a bad end time" do
        @listing.event_end_time = ''
        @listing.should_not be_valid
      end

      it "should reject end time < start time" do
        @listing.event_end_date = @listing.event_start_date
        @listing.event_end_time = Time.now.advance(:hours => -2)
        @listing.should_not be_valid
      end

      it "should not be valid without a end time" do
        @listing.event_end_time = nil
        @listing.should_not be_valid
      end
    end
  end
end
