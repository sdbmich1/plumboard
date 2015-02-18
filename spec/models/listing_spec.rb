require 'spec_helper'

describe Listing do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.create(:listing, seller_id: @user.id, quantity: 1) 
  end

  def create_invoice status='active', qty=1
    @listing2 = create :listing, seller_id: @user.id, quantity: 2, title: 'Leather Coat'
    @buyer = create(:pixi_user)
    @invoice = @user.invoices.build attributes_for(:invoice, buyer_id: @buyer.id, status: status) 
    @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id, quantity: qty 
    @details2 = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing2.pixi_id, quantity: 3 
    @invoice.save!
  end

  subject { @listing }
  
  # describe "testing attributes" do
  #  it_behaves_like "an Listing class", @listing
  # end

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
  it { should respond_to(:pixan_id) }
  it { should respond_to(:job_type_code) }
  it { should respond_to(:event_type_code) }
  it { should respond_to(:explanation) }
  it { should respond_to(:repost_flg) }
  it { should respond_to(:quantity) }
  it { should respond_to(:condition_type_code) }
  it { should respond_to(:color) }
  it { should respond_to(:other_id) }
  it { should respond_to(:mileage) }
  it { should respond_to(:item_type) }
  it { should respond_to(:item_size) }

  it { should respond_to(:user) }
  it { should respond_to(:site) }
  it { should respond_to(:posts) }
  it { should respond_to(:conversations) }
  it { should respond_to(:invoices) }
  it { should respond_to(:site_listings) }
  it { should respond_to(:transaction) }
  it { should respond_to(:pictures) }
  it { should respond_to(:contacts) }
  it { should respond_to(:category) }
  it { should respond_to(:job_type) }
  it { should respond_to(:event_type) }
  it { should belong_to(:event_type).with_foreign_key('event_type_code') }
  it { should respond_to(:condition_type) }
  it { should belong_to(:condition_type).with_foreign_key('condition_type_code') }
  it { should respond_to(:comments) }
  it { should respond_to(:pixi_likes) }
  it { should have_many(:pixi_likes).with_foreign_key('pixi_id') }
  it { should respond_to(:pixi_wants) }
  it { should have_many(:pixi_wants).with_foreign_key('pixi_id') }
  it { should respond_to(:saved_listings) }
  it { should have_many(:saved_listings).with_foreign_key('pixi_id') }
  it { should respond_to(:buyer) }
  it { should belong_to(:buyer).with_foreign_key('buyer_id') }

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

  describe "active_invoices" do
    it 'should not get listings if none are invoiced' do
      @listing.status = 'active'
      @listing.save
      Listing.active.should_not be_empty
      Listing.active_invoices.should be_empty
    end

    it 'should get listings' do
      create_invoice
      Listing.active_invoices.should_not be_empty
    end
  end

  describe "check_category_and_location" do
    it "should get all listings of given status if category and location are not specified" do
      Listing.check_category_and_location('active', nil, nil).should_not be_empty
    end

    it "should get listing when category and location are specified" do      
      Listing.check_category_and_location('active', @listing.category_id, @listing.site_id).should_not be_empty
    end

    it "should not return anything if no listings meet the parameters" do
      Listing.check_category_and_location('removed', 100, 900).should be_empty
    end
  end

  describe "check_invoiced_category_and_location" do
    before do
      create_invoice
    end      

    it "should get all listings of given status if category and location are not specified" do
      Listing.check_invoiced_category_and_location(nil, nil).should_not be_empty
    end

    it "should get listing when category and location are specified" do      
      Listing.check_invoiced_category_and_location(@listing.category_id, @listing.site_id).should_not be_empty
    end

    it "should not return anything if no listings meet the parameters" do
      Listing.check_invoiced_category_and_location(100, 900).should be_empty
    end
  end

  describe "has_enough_pixis?" do
    it "returns true" do
      stub_const("MIN_PIXI_COUNT", 0)
      expect(MIN_PIXI_COUNT).to eq(0)
      expect(Listing.has_enough_pixis?(@listing.category_id, @listing.site_id, 1)).to be_true
    end

    it "returns false" do
      stub_const("MIN_PIXI_COUNT", 500)
      expect(MIN_PIXI_COUNT).to eq(500)
      expect(Listing.has_enough_pixis?(@listing.category_id, 1, 1)).not_to be_true
    end
  end

  describe "active_by_city" do
    it { Listing.active_by_city(0, 1, 1).should_not include @listing } 
    it "finds active pixis by city" do
      @site = create :site, name: 'Detroit', org_type: 'city'
      @site.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI'
      listing = create(:listing, seller_id: @user.id, site_id: @site.id) 
      expect(Listing.active_by_city('Detroit', 'MI', 1).count).to eq(1)
    end
  end

  describe "category_by_site" do
    it { Listing.get_category_by_site(0, 1, 1).should_not include @listing } 
    it { Listing.get_category_by_site(@listing.category_id, @listing.site_id, 1).should_not be_empty }
  end

  describe "seller listings" do 
    it "includes seller listings" do 
      @listing.seller_id = 1
      @listing.save
      @user.uid = 1
      @user.save
      Listing.get_by_seller(@user, false).should_not be_empty  
    end

    it "does not get all listings for non-admin" do
      @listing.seller_id = 100
      @listing.save
      Listing.get_by_seller(@user, false).should_not include @listing
    end

    it "gets all listings for admin" do
      @other = FactoryGirl.create(:pixi_user)
      listing = FactoryGirl.create(:listing, seller_id: @other.id) 
      @user.user_type_code = "AD"
      @user.uid = 0
      @user.save
      expect(Listing.get_by_seller(@user).count).to eq 2
    end
  end

  describe "buyer listings" do 
    it { Listing.get_by_buyer(0).should_not include @listing } 

    it "includes buyer listings" do 
      @listing.buyer_id = 1
      @listing.save
      Listing.get_by_buyer(1).should_not be_empty  
    end
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

  describe 'site_address' do
    it 'has site address' do
      @site = create :site
      @contact = @site.contacts.create FactoryGirl.attributes_for(:contact)
      listing = create :listing, seller_id: @user.id, site_id: @site.id
      expect(listing.site_address).to eq @contact.full_address
    end

    it 'has no site address' do
      expect(@listing.site_address).to eq @listing.site_name
    end
  end

  describe "should return site count > 0" do 
    it { @listing.get_site_count.should_not == 0 } 
  end

  describe "should find correct category name" do 
    it { @listing.category_name.should == 'Foo Bar' } 
    it "should not find correct category name" do 
      @listing.category_id = 100 
      @listing.category_name.should be_nil  
    end
  end

  describe "seller name" do 
    it { expect(@listing.seller_name).to eq(@user.name) } 
    it "does not find seller name" do 
      @listing.seller_id = 100 
      expect(@listing.seller_name).not_to eq(@user.name)
    end
  end

  describe "seller email" do 
    it { expect(@listing.seller_email).to eq(@user.email) } 
    it "does not find seller email" do 
      @listing.seller_id = 100 
      expect(@listing.seller_email).not_to eq(@user.email)
    end
  end

  describe "seller photo" do 
    it { @listing.seller_photo.should_not be_nil } 
    it 'does not return seller photo' do 
      @listing.seller_id = 100 
      @listing.seller_photo.should be_nil  
    end
  end

  describe "seller rating count" do 
    it { @listing.seller_rating_count.should == 0 } 
    it 'returns seller rating count' do 
      @buyer = create(:pixi_user)
      @rating = @buyer.ratings.create FactoryGirl.attributes_for :rating, seller_id: @user.id, pixi_id: @listing.id
      expect(@listing.seller_rating_count).to eq(1)
    end
  end

  describe "condition" do 
    before { create :condition_type, code: 'N' }
    it { expect(@listing.condition).to be_nil } 
    it "finds condition" do 
      @listing.condition_type_code = 'N' 
      expect(@listing.condition).not_to be_nil
    end
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

  describe "pixter" do 
    before do
      @pixter = create :pixi_user, user_type_code: 'PT'
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
      @listing = FactoryGirl.create(:listing, seller_id: @user.id, pixan_id: @pixter.id) 
    end

    it "should verify user is pixter" do 
      @listing.pixter?(@pixter).should be_true 
    end

    it "should not verify user is pixter" do 
      @listing.pixter?(@user2).should_not be_true 
    end
  end

  describe "editable" do 
    before do
      @pixter = create :pixi_user, user_type_code: 'PT'
      @admin = create :admin, confirmed_at: Time.now
      @support = create :support, confirmed_at: Time.now
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
      @listing = FactoryGirl.create(:listing, seller_id: @user.id, pixan_id: @pixter.id) 
      @sold = FactoryGirl.create(:listing, seller_id: @user.id, pixan_id: @pixter.id, status: 'sold') 
    end

    it "is editable" do 
      @listing.editable?(@pixter).should be_true 
      @listing.editable?(@user).should be_true 
      @listing.editable?(@admin).should be_true 
      @listing.editable?(@support).should be_true 
    end

    it "is not editable" do 
      @listing.editable?(@user2).should_not be_true 
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

  describe "nice title" do 

    it "should return a nice title" do 
      @listing.nice_title.should be_true 
    end

    it "should not return a nice title" do 
      @listing.title = nil
      @listing.nice_title.should_not be_true 
    end

    it "returns a nice title w/ $" do 
      @listing.title = 'Shirt $100'
      expect(@listing.nice_title(false)).not_to eq 'Shirt $100' 
      expect(@listing.nice_title(false)).to eq 'Shirt' 
    end
  end

  describe "is not pixi_post" do 
    it { @listing.pixi_post?.should_not be_true }
  end

  describe "is a pixi_post" do 
    before do 
      @pixan = FactoryGirl.create(:contact_user) 
      @listing.pixan_id = @pixan.id 
    end
    it { @listing.pixi_post?.should be_true }
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

  describe 'contacts' do
    before(:each) do
      @sr = @listing.contacts.create FactoryGirl.attributes_for(:contact)
    end
				            
    it "should have many contacts" do 
      @listing.contacts.should include(@sr)
    end

    it "should destroy associated contacts" do
      @listing.destroy
      [@sr].each do |s|
         Contact.find_by_id(s.id).should be_nil
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
      create_invoice
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

  describe 'closed?' do
    it 'should return true' do
      @listing.status = 'closed'
      @listing.closed?.should be_true
    end

    it 'should not return true' do
      @listing.closed?.should_not be_true
    end
  end

  describe 'removed?' do
    it 'should return true' do
      @listing.status = 'removed'
      @listing.removed?.should be_true
    end

    it 'should not return true' do
      @listing.removed?.should_not be_true
    end
  end

  describe 'inactive?' do
    it 'should return true' do
      @listing.status = 'inactive'
      @listing.inactive?.should be_true
    end

    it 'should not return true' do
      @listing.inactive?.should_not be_true
    end
  end

  describe 'mark_as_sold' do
    before :each, run: true do
      create_invoice 'paid'
    end

    it 'returns true', run: true do
      @listing.mark_as_sold.should be_true
    end

    it 'does not mark when amt left > 0' do
      @listing.update_attribute(:quantity, 5)
      create_invoice 'paid'
      @listing.mark_as_sold.should_not be_true
    end

    it 'does not mark when already sold' do
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

  def check_cat_type model, val, flg=false
    if flg
      @cat = FactoryGirl.create(:category, name: 'Test Type', category_type_code: 'event', pixi_type: 'premium') 
      model.category_id = @cat.id
    end
    model.is_category_type?(val)
  end

  describe '.is_category_type?' do
    it { check_cat_type(@listing, 'event').should be_false }
    it "is an category type" do
      check_cat_type(@listing, 'event', true).should be_true
      check_cat_type(@listing, ['service', 'sales', 'event'], true).should be_true
      check_cat_type(@listing, %w(service sales event), true).should be_true
    end
  end

  describe '.has_status?' do
    it { @listing.has_status?('').should be_false }
    it "return true" do
      @listing.has_status?('active').should be_true
      @listing.has_status?(['sold', 'removed','active']).should be_true
    end
  end

  describe '.event?' do
    it { @listing.event?.should be_false }
    it "is an event" do
      @cat = FactoryGirl.create(:category, name: 'Event', category_type_code: 'event', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      @listing.event?.should be_true
    end
  end

  describe '.has_year?' do
    it { @listing.has_year?.should be_false }

    it "when it's an asset" do
      @cat = FactoryGirl.create(:category, name: 'Homes', category_type_code: 'asset', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      @listing.has_year?.should be_true 
    end

    it "when it's an vehicle" do
      @cat = FactoryGirl.create(:category, name: 'Homes', category_type_code: 'vehicle', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      @listing.has_year?.should be_true 
    end
  end

  describe '.job?' do
    before :each, run: true do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'employment', pixi_type: 'premium') 
    end

    it "is not a job" do
      @listing.job?.should be_false 
    end

    it "is a job", run: true do
      @listing.category_id = @cat.id
      @listing.job?.should be_true 
    end

    it "is not valid", run: true  do
      @listing.category_id = @cat.id
      @listing.should_not be_valid
    end

    it "is valid", run: true do
      create :job_type
      @listing.category_id = @cat.id
      @listing.job_type_code = 'CT'
      @listing.should be_valid
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

  describe "saved" do 
    before(:each) do
      @usr = FactoryGirl.create :pixi_user
      @saved_listing = @user.saved_listings.create FactoryGirl.attributes_for :saved_listing, pixi_id: @listing.pixi_id
      @usr.saved_listings.create FactoryGirl.attributes_for :saved_listing, pixi_id: @listing.pixi_id, status: 'sold'
    end

    it "checks saved list" do
      Listing.saved_list(@usr).should_not include @listing  
      Listing.saved_list(@user).should_not be_empty 
    end

    it "is saved" do
      expect(@listing.saved_count).not_to eq(0) 
      expect(@listing.is_saved?).to eq(true) 
      expect(@listing.user_saved?(@user)).not_to be_nil 
    end

    it "is not saved" do
      listing = create(:listing, seller_id: @user.id, title: 'Hair brush') 
      expect(listing.saved_count).to eq(0)
      expect(listing.is_saved?).to eq(false)
      expect(@listing.user_saved?(@usr)).not_to eq(true) 
    end
  end

  describe "send_saved_pixi_removed" do
    before(:each) do
      @saved_listing = FactoryGirl.create(:saved_listing, user_id: @user.id, pixi_id: @listing.pixi_id)
    end

    it 'delivers the email' do
      @listing.status = 'sold'
      @listing.save; sleep 2
      expect(ActionMailer::Base.deliveries.last.subject).to eql('Saved Pixi is Sold/Removed') 
    end

    it 'sends email to right user' do
      @listing.status = 'removed'
      @listing.save; sleep 2
      expect(ActionMailer::Base.deliveries.last.to).to eql([@saved_listing.user.email])
    end

    it 'delivers email to all saved pixi users' do
      user2 = FactoryGirl.create :pixi_user
      saved_listing2 = FactoryGirl.create(:saved_listing, user_id: user2.id, pixi_id: @listing.pixi_id)
      expect {
        @listing.status = 'closed'
        @listing.save; sleep 2
      }.to change{ActionMailer::Base.deliveries.length}.by(2)
    end

    context 'when no saved listings' do
      it 'does not deliver email' do
        listing = FactoryGirl.create(:listing, seller_id: @user.id)
        listing.status = 'sold'
        listing.save; sleep 2
        expect(ActionMailer::Base.deliveries.last.subject).not_to eql('Saved Pixi is Sold/Removed')
      end
    end

    context 'when buyer saved the listing' do
      let(:buyer) { FactoryGirl.create :pixi_user }

      it 'does not send email to buyer' do
        listing = FactoryGirl.create(:listing, seller_id: @user.id)
        saved_listing = FactoryGirl.create(:saved_listing, user_id: buyer.id, pixi_id: listing.pixi_id)
        listing.status = 'inactive'
        listing.buyer_id = buyer.id
        listing.save; sleep 2
        expect(ActionMailer::Base.deliveries.last.subject).not_to eql('Saved Pixi is Sold/Removed')
      end
    end

    context 'when checking email content' do
      let (:mail) { UserMailer.send_saved_pixi_removed(@saved_listing) }

      it 'renders the subject' do
        expect(mail.subject).to eql('Saved Pixi is Sold/Removed')
      end

      it 'renders the receiver email' do
        expect(mail.to).to eql([@saved_listing.user.email])
      end

      it 'renders the sender email' do
        expect(mail.from).to eql(['support@pixiboard.com'])
      end
    end

    it 'does not send message on repost' do
      @expired = FactoryGirl.create(:listing, seller_id: @user.id, status: 'expired') 
      @expired.status = 'active'
      @expired.save
      expect(ActionMailer::Base.deliveries.last.subject).not_to eql('Saved Pixi is Sold/Removed')
    end
  end

  describe "wanted" do 
    before(:each) do
      @usr = create :pixi_user
      @pixi_want = @user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
    end

    it { Listing.wanted_list(@usr).should_not include @listing } 
    it { Listing.wanted_list(@user).should_not be_empty }
    it { expect(@listing.wanted_count).to eq(1) }
    it { expect(@listing.is_wanted?).to eq(true) }

    it "is not wanted" do
      listing = create(:listing, seller_id: @user.id, title: 'Hair brush') 
      expect(listing.wanted_count).to eq(0)
      expect(listing.is_wanted?).to eq(false)
    end

    it { expect(Listing.wanted_users(@listing.pixi_id).first.name).to eq(@user.name) }
    it { expect(Listing.wanted_users(@listing.pixi_id)).not_to include(@usr) }

    it { expect(@listing.user_wanted?(@user)).not_to be_nil }
    it { expect(@listing.user_wanted?(@usr)).not_to eq(true) }

    it "shows all wanted pixis for admin" do
      @admin_user = create :admin
      @admin_user.user_type_code = 'AD'
      @admin_user.save!
      expect(Listing.wanted_list(@admin_user, 1, @listing.category_id, @listing.site_id).count).not_to eq 0
      Listing.wanted_list(@admin_user, 1, @listing.category_id, @listing.site_id).should include @listing
      Listing.wanted_list(@usr, 1, @listing.category_id, @listing.site_id).should_not include @listing
    end
  end

  describe "cool" do 
    before(:each) do
      @usr = FactoryGirl.create :pixi_user
      @pixi_like = @user.pixi_likes.create FactoryGirl.attributes_for :pixi_like, pixi_id: @listing.pixi_id
    end

    it { Listing.cool_list(@usr).should_not include @listing } 
    it { Listing.cool_list(@user).should_not be_empty }
    it { expect(@listing.liked_count).to eq(1) }
    it { expect(@listing.is_liked?).to eq(true) }

    it "is not liked" do
      listing = create(:listing, seller_id: @user.id, title: 'Hair brush') 
      expect(listing.liked_count).to eq(0)
      expect(listing.is_liked?).to eq(false)
    end

    it { expect(@listing.user_liked?(@user)).not_to be_nil }
    it { expect(@listing.user_liked?(@usr)).not_to eq(true) }
  end

  describe 'msg count' do
    it { expect(@listing.msg_count).to eq(0) }

    it "has messages" do
      @recipient = FactoryGirl.create :pixi_user
      @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id
      @post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, conversation_id: @conversation.id, pixi_id: @listing.pixi_id
      expect(@listing.msg_count).to eq(1)
    end
  end

  describe "find_pixi" do
    it 'finds a pixi' do
      expect(Listing.find_pixi(@listing.pixi_id)).not_to be_nil
    end

    it 'does not find pixi' do
      expect(Listing.find_pixi(0)).to be_nil
    end
  end

  describe "dup pixi" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it "does not return new listing" do 
      listing = FactoryGirl.build :listing, seller_id: user.id 
      listing.dup_pixi(false).should_not be_nil
    end

    it "returns new listing" do 
      new_pixi = listing.dup_pixi(false)
      expect(new_pixi.status).to eq('edit')
      expect(new_pixi.title).to eq(listing.title)
      expect(new_pixi.id).not_to eq(listing.id)
      expect(new_pixi.pictures.size).to eq(listing.pictures.size)
    end
  end

  describe "date display methods" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it "does not show start date" do
      listing.start_date = nil
      listing.start_date.should be_nil
    end

    it { listing.start_date.should_not be_nil }
  end

  describe 'format_date' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it "does not show local updated date" do
      listing.updated_at = nil
      expect(listing.format_date(listing.updated_at)).to eq Time.now.strftime('%m/%d/%Y %l:%M %p')
    end

    it "show current updated date" do
      expect(listing.format_date(listing.updated_at)).to eq listing.updated_at.strftime('%m/%d/%Y %l:%M %p')
    end

    it "shows local updated date" do
      listing.lat, listing.lng = 35.1498, -90.0492
      expect(listing.format_date(listing.updated_at)).not_to eq Time.now.strftime('%m/%d/%Y %l:%M %p')
    end
  end

  describe 'display_date' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it "does not show local updated date" do
      listing.updated_at = nil
      expect(listing.display_date(listing.updated_at)).to eq Time.now.strftime('%m/%d/%Y %l:%M %p')
    end

    it "show current updated date" do
      expect(listing.display_date(listing.updated_at)).not_to eq listing.updated_at.strftime('%m/%d/%Y %l:%M %p')
    end

    it "shows local updated date" do
      listing.lat, listing.lng = 35.1498, -90.0492
      expect(listing.display_date(listing.updated_at)).to eq Time.now.strftime('%m/%d/%Y %l:%M %p')
      expect(listing.display_date(listing.updated_at)).not_to eq listing.updated_at.strftime('%m/%d/%Y %l:%M %p')
    end
  end

  describe "sync saved pixis" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it 'marks saved pixis as sold' do
      expect {
        create(:saved_listing, user_id: user.id, pixi_id: listing.pixi_id); sleep 1
        listing.status = 'sold'
        listing.save; sleep 2
      }.to change{ SavedListing.where(:status => 'sold').count }.by(1)
    end

    it 'marks saved pixis as closed' do
      expect {
        create(:saved_listing, user_id: user.id, pixi_id: listing.pixi_id); sleep 1
        listing.status = 'closed'
        listing.save; sleep 2
      }.to change{ SavedListing.where(:status => 'closed').count }.by(1)
    end

    it 'marks saved pixis as inactive' do
      expect {
        create(:saved_listing, user_id: user.id, pixi_id: listing.pixi_id); sleep 1
        listing.status = 'inactive'
        listing.save; sleep 2
      }.to change{ SavedListing.where(:status => 'inactive').count }.by(1)
    end

    it 'marks saved pixis as removed' do
      expect {
        create(:saved_listing, user_id: user.id, pixi_id: listing.pixi_id); sleep 1
        listing.status = 'removed'
        listing.save; sleep 2
      }.to change{ SavedListing.where(:status => 'removed').count }.by(1)
    end
  end

  describe 'remove_item_list' do
    it 'is a job' do
      @cat = FactoryGirl.create(:category, name: 'Job', category_type_code: 'employment', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      expect(@listing.remove_item_list).not_to include('Event Cancelled') 
      expect(@listing.remove_item_list).to include('Removed Job') 
      expect(@listing.remove_item_list).not_to include('Changed Mind') 
    end

    it 'is an event' do
      @cat = FactoryGirl.create(:category, name: 'Event', category_type_code: 'event', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      expect(@listing.remove_item_list).to include('Event Cancelled') 
      expect(@listing.remove_item_list).not_to include('Removed Job') 
      expect(@listing.remove_item_list).not_to include('Changed Mind') 
    end

    it 'is not a job or event' do
      expect(@listing.remove_item_list).not_to include('Event Cancelled') 
      expect(@listing.remove_item_list).not_to include('Removed Job') 
      expect(@listing.remove_item_list).to include('Changed Mind') 
    end
  end

  describe 'job_type_name' do
    it "shows description" do
      create :job_type
      @listing.job_type_code = 'CT'
      expect(@listing.job_type_name).to eq 'Contract'
    end

    it "does not show description" do
      expect(@listing.job_type_name).to be_nil
    end
  end

  describe "date validations" do
    before do
      @cat = FactoryGirl.create(:category, name: 'Event', category_type_code: 'event', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      @listing.event_type_code = 'party'
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

  describe "close_pixis" do
    it "should not close pixi if end_date is invalid" do
      @listing.end_date = nil
      @listing.save
      Listing.close_pixis
      @listing.reload.status.should_not == 'closed'
    end
    it "should not close pixi with an end_date >= today" do
      @listing.end_date = Date.today + 1.days
      @listing.save
      Listing.close_pixis
      @listing.reload.status.should_not == 'closed'
    end
    it "should close pixi with an end_date < today" do
      @listing.end_date = Date.today - 1.days
      @listing.save
      Listing.close_pixis
      @listing.reload.status.should == 'closed'
    end
  end

  describe '.event_type' do
    before do
      @etype = FactoryGirl.create(:event_type, code: 'party', description: 'Parties, Galas, and Gatherings')
      @cat = FactoryGirl.create(:category, name: 'Events', category_type_code: 'event')
      @listing1 = FactoryGirl.create(:listing, seller_id: @user.id)
      @listing1.category_id = @cat.id
      @listing1.event_type_code = 'party'
    end
    
    it "should be an event" do
      expect(@listing1.event?).to be_true
    end
    
    it "should respond to .event_type" do
      expect(@listing1.event_type_code).to eq 'party'
    end
    
    it "should respond to .event_type" do
      expect(@listing.event_type_code).not_to eq 'party'
    end

    it "shows event_type description" do
      expect(@listing1.event_type_descr).to eq @etype.description.titleize
    end

    it "does not show event_type description" do
      expect(@listing.event_type_descr).to be_nil
    end
  end
  
  describe 'async_send_notifications' do

    def send_mailer model, msg
      @mailer = mock(UserMailer)
      UserMailer.stub!(:delay).and_return(@mailer)
      @mailer.stub(msg.to_sym).with(model).and_return(@mailer)
    end

    it 'adds abp pixi points' do
      create(:listing, seller_id: @user.id)
      expect(@user.user_pixi_points.count).not_to eq(0)
      @user.user_pixi_points.find_by_code('abp').code.should == 'abp'
      @user.user_pixi_points.find_by_code('app').should be_nil
    end

    it 'adds app pixi points' do
      @category = create(:category, pixi_type: 'premium')
      create(:listing, category_id: @category.id, seller_id: @user.id)
      expect(@user.user_pixi_points.count).not_to eq(0)
      @user.user_pixi_points.find_by_code('app').code.should == 'app'
    end

    it 'delivers the submitted pixi message' do
      listing = create(:listing, seller_id: @user.id)
      send_mailer listing, 'send_approval'
    end

    it 'removes temp_listing after create' do
      temp_listing = create(:temp_listing, seller_id: @user.id)
      pid = temp_listing.pixi_id
      listing = create(:listing, seller_id: @user.id, pixi_id: temp_listing.pixi_id)
      sleep 2;
      expect(TempListing.where(pixi_id: pid).count).to eq 0
    end

    it 'delivers approved pixi message' do
      create :admin, email: PIXI_EMAIL
      listing = create(:listing, seller_id: @user.id)
      send_mailer listing, 'send_approval'
      expect(Conversation.all.count).not_to eq(0)
      expect(Post.all.count).not_to eq(0)
      SystemMessenger.stub!(:send_system_message).with(@user, listing, 'approve').and_return(true)
    end

    it 'delivers reposted pixi message' do
      create :admin, email: PIXI_EMAIL
      listing = create(:listing, seller_id: @user.id, repost_flg: true)
      expect(Listing.count).to eq 2
      send_mailer listing, 'send_approval'
      expect(Conversation.all.count).not_to eq(0)
      expect(Post.all.count).not_to eq(0)
      SystemMessenger.stub!(:send_system_message).with(@user, listing, 'repost').and_return(true)
    end
  end

  describe 'set_invoice_status' do
    before do 
      create_invoice
    end

    it 'sets invoice status to removed' do
      expect {
        create(:saved_listing, user_id: @buyer.id, pixi_id: @listing.pixi_id); sleep 1
        @listing.status = 'removed'
        @listing.save
      }.to change{ Invoice.where(:status => 'removed').count }.by(1)
    end

    it 'does not set invoice status' do
      @listing.status = 'sold'
      @listing.save
      expect(@invoice.status).not_to eq 'removed'
    end
  end

  describe 'expired?' do
    it 'should return true' do
      @listing.status = 'expired'
      @listing.expired?.should be_true
    end

    it 'should not return true' do
      @listing.expired?.should_not be_true
    end
  end

  describe 'repost' do
    it 'sets status to active if listing is expired' do
      @listing.status = 'expired'
      @listing.repost; sleep 2
      @listing.active?.should be_true
      expect(@listing.repost_flg).to be_true
      expect(ActionMailer::Base.deliveries.last.subject).to eql("Pixi Reposted: #{@listing.title} ") 
    end

    it 'sets status to active if listing is removed' do
      @listing.status = 'removed'
      @listing.explanation = 'Changed Mind'
      @listing.save
      @listing.repost
      @listing.active?.should be_true
      expect(@listing.repost_flg).to be_true
      expect(@listing.explanation).to be_nil
      expect(ActionMailer::Base.deliveries.last.subject).to eql("Pixi Reposted: #{@listing.title} ") 
    end

    it 'calls repost_pixi if listing is sold' do
      @listing.status = 'sold'
      picture = @listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo0.jpg")
      @listing.save
      expect(@listing.repost).to be_true
      expect(Listing.all.count).to eq 2
      expect(Listing.first.active?).to be_true
      expect(Listing.first.pictures.size).to eq @listing.pictures.size
      expect(Listing.first.repost_flg).to be_true
    end

    it 'returns false if listing is not expired/sold' do
      @listing.status = 'active'
      @listing.repost.should be_false
    end
  end

  describe 'soon_expiring_pixis' do
    it "includes active listings" do 
      @listing.end_date = Date.today + 4.days
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(4).should_not be_empty  
    end
	
    it "includes expired listings" do
      @listing.end_date = Date.today + 4.days
      @listing.status = 'expired'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(4, 'expired').should_not be_empty  
    end
	
      it "includes expired listings" do
      @listing.end_date = Date.today + 4.days
      @listing.status = 'expired'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(4, ['expired', 'active']).should_not be_empty  
    end
	
      it "includes active listings" do
      @listing.end_date = Date.today + 5.days
      @listing.status = 'active'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(5, ['expired', 'active']).should_not be_empty  
    end
	
      it "includes default active listings" do
      @listing.end_date = Date.today + 7.days
      @listing.status = 'active'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis().should_not be_empty  
    end
  end
  
  
  describe 'not soon_expiring_pixis' do  
    it "does not include active listings" do 
      @listing.end_date = Date.today + 10.days
      @listing.status = 'active'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(8).should be_empty  
    end
	
    it "does not include expired listings" do 
      @listing.end_date = Date.today + 4.days
      @listing.status = 'expired'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(3).should be_empty  
    end
	
    it "does not include expiring early listings" do 
      @listing.end_date = Date.today + 4.days
      @listing.status = 'expired'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(5).should be_empty  
    end
	
    it "does not include active listings" do 
      @listing.end_date = Date.today + 4.days
      @listing.status = 'active'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(5, nil).should be_empty  
    end
	
    it "does not include active listings" do 
      @listing.end_date = Date.today + 4.days
      @listing.status = 'active'
      @listing.save
      @listing.reload
      Listing.soon_expiring_pixis(5, ['expired', 'new']).should be_empty  
    end
  end

  describe "delete temp pixi" do
    it { @listing.delete_temp_pixi(@listing.pixi_id).should be_blank }

    it "removes temp pixi" do
      temp_listing = create(:temp_listing, seller_id: @user.id)
      listing = create(:listing, seller_id: @user.id, pixi_id: temp_listing.pixi_id)
      expect(listing.pixi_id).to eq temp_listing.pixi_id
      expect{ 
         listing.delete_temp_pixi(listing.pixi_id); sleep 2;
      }.not_to be_blank
    end
  end

  describe "sold count" do
    before :each, run: true do
      create_invoice 'paid'
    end
    it { expect(@listing.sold_count).to eq 0 }
    it "has count = 1", run: true do
      expect(@listing.sold_count).to eq 1
    end
    it "has count > 1" do
      create_invoice 'paid', 3
      expect(@listing.sold_count).to eq 3
    end
  end

  describe "amt left" do
    before :each, run: true do
      @listing.update_attribute(:quantity, 3)
      create_invoice 'paid'
    end
    it { expect(@listing.amt_left).to eq 1 }
    it "has count > 1", run: true do
      expect(@listing.amt_left).not_to eq 1
    end
  end

  describe "active_by_state" do
    it { Listing.active_by_state('MI').should_not include @listing } 
    it "finds active pixis by state" do
      @site = create(:site, name: 'Detroit', org_type: 'city')
      @site.contacts.create(FactoryGirl.attributes_for(:contact, address: 'Metro', city: 'Detroit', state: 'MI'))
      listing = create(:listing, seller_id: @user.id, site_id: @site.id) 
      expect(Listing.active_by_state('MI').count).to eq(1)
    end
  end

  describe "active_by_country" do
    it { Listing.active_by_country('United States of America').should_not include @listing } 
    it "finds active pixis by country" do
      @site = create(:site, name: 'Detroit', org_type: 'city')
      @site.contacts.create(FactoryGirl.attributes_for(:contact, address: 'Metro', city: 'Detroit', state: 'MI', country: 'United States of America'))
      listing = create(:listing, seller_id: @user.id, site_id: @site.id) 
      expect(Listing.active_by_country('United States of America').count).to eq(1)
    end
  end

  describe "get_by_city" do
    it { Listing.get_by_city(0, 1, 1).should_not include @listing } 
    it "should be able to toggle get_active" do
      @listing.status = 'expired'
      @listing.save!
      Listing.get_by_city(@listing.category_id, @listing.site_id, 1, true).should be_empty
      Listing.get_by_city(@listing.category_id, @listing.site_id, 1, false).should_not be_empty
    end

    it "finds active pixis by org_type" do
      ['city', 'region', 'state', 'country'].each { |org_type|
        site = create(:site, name: 'Detroit', org_type: org_type)
        lat, lng = Geocoder.coordinates('Detroit, MI')
        site.contacts.create(FactoryGirl.attributes_for(:contact, address: 'Metro', city: 'Detroit', state: 'MI',
          country: 'United States of America', lat: lat, lng: lng))
        listing = create(:listing, seller_id: @user.id, site_id: site.id, category_id: @category.id) 
        expect(Listing.get_by_city(listing.category_id, listing.site_id).first).to eq(listing)
        listing.destroy
      }
    end
  end
end
