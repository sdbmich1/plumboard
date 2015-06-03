require 'spec_helper'

describe Listing do
  before(:all) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
  end
  before(:each) do
    @listing = FactoryGirl.build(:listing, seller_id: @user.id, quantity: 1) 
  end

  def create_invoice status='unpaid', qty=1, flg=true
    @listing.save!
    @listing2 = create :listing, seller_id: @user.id, quantity: 2, title: 'Leather Coat'
    @buyer = create(:pixi_user)
    @invoice = @user.invoices.build attributes_for(:invoice, buyer_id: @buyer.id, status: status) 
    @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id, quantity: qty 
    @details2 = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing2.pixi_id, quantity: 3 if flg
    @invoice.save!
  end

  subject { @listing }
  
  # describe "testing attributes" do
  #  it_behaves_like "an Listing class", @listing
  # end

  describe 'attributes', base: true do
    let(:listing) { FactoryGirl.build :listing, seller_id: user.id }
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
    it { should respond_to(:bed_no) }
    it { should respond_to(:bath_no) }
    it { should respond_to(:term) }
    it { should respond_to(:avail_date) }

    it { should respond_to(:user) }
    it { should respond_to(:site) }
    it { should respond_to(:posts) }
    it { should respond_to(:conversations) }
    it { should respond_to(:invoices) }
    #it { should respond_to(:site_listings) }
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
    it { should have_many(:saved_listings).with_foreign_key('pixi_id')}
    it { should have_many(:active_saved_listings).with_foreign_key('pixi_id').conditions(:status=>"active") }
    it { should respond_to(:buyer) }
    it { should belong_to(:buyer).with_foreign_key('buyer_id') }
    it { should have_many(:active_pixi_wants).class_name('PixiWant').with_foreign_key('pixi_id').conditions(:status=>"active") }
    it { should accept_nested_attributes_for(:contacts).allow_destroy(true) }
    context 'IDs' do
      %w(site_id seller_id category_id transaction_id).each do |fld|
        it_behaves_like 'an ID', fld
      end
    end
    context 'dates' do
      %w(start_date end_date event_start_date event_end_date).each do |fld|
        it_behaves_like 'a date', fld
      end
    end
    it_behaves_like 'an amount', 'price', 15000
    it { should allow_value('chair').for(:title) }
    it { should_not allow_value("a"*81).for(:title) }
    it { should_not allow_value("").for(:title) }
    it { should allow_value('chair').for(:description) }
    it { should_not allow_value("").for(:description) }

    context 'status' do
      %w(active edit pending denied expired sold closed inactive removed).each do |fld|
        it_behaves_like 'a status field', :listing, fld
      end
    end
  end

  describe "inactive listings", base: true do
    before(:each) do
      @listing.status = 'inactive' 
      @listing.save!
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

  describe "includes active listings", base: true  do 
    before { @listing.save! }
    it { Listing.active.should be_true }
    it { Listing.active_page(1).should be_true }
    it { Listing.get_by_status('active').should_not be_empty }
  end

  describe "site listings", base: true  do 
    before { @listing.save! }
    it { Listing.get_by_site(0).should_not include @listing } 
    it { Listing.get_by_site(@listing.site.id).should_not be_empty }
  end

  describe "category listings", base: true   do 
    it { Listing.get_by_category(0).should_not include @listing } 
    it 'finds listing by category' do
      @listing.save!
      Listing.get_by_category(@listing.category_id).should_not be_empty
    end
  end

  describe "active_invoices", main: true  do
    it 'should not get listings if none are invoiced' do
      @listing.status = 'active'
      @listing.save
      Listing.active.should_not be_empty
      Listing.active_invoices.should be_empty
    end

    it 'should get listings' do
      create_invoice "unpaid"
      Listing.active_invoices.should_not be_empty
    end
  end

  describe "check_category_and_location", main: true  do
    before { @listing.save! }
    it "should get all listings of given status if category and location are not specified" do
      Listing.check_category_and_location('active', nil, nil, true).should_not be_empty
    end

    it "should get listing when category and location are specified" do      
      Listing.check_category_and_location('active', @listing.category_id, @listing.site_id, true).should_not be_empty
    end

    it "should not return anything if no listings meet the parameters" do
      Listing.check_category_and_location('removed', 100, 900, true).should be_empty
    end
  end

  describe "check_invoiced_category_and_location", main: true  do
    before do
      @listing.save!
      create_invoice "unpaid"
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

  describe "has_enough_pixis?", main: true  do
    before { @listing.save! }
    it "returns true" do
      stub_const("MIN_PIXI_COUNT", 0)
      expect(MIN_PIXI_COUNT).to eq(0)
      expect(Listing.has_enough_pixis?(@listing.category_id, @listing.site_id)).to be_true
    end

    it "returns false" do
      stub_const("MIN_PIXI_COUNT", 500)
      expect(MIN_PIXI_COUNT).to eq(500)
      expect(Listing.has_enough_pixis?(@listing.category_id, 1)).not_to be_true
    end
  end

  describe "seller listings", main: true  do 
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
      @listing.save
      @other = FactoryGirl.create(:pixi_user)
      listing = FactoryGirl.create(:listing, seller_id: @other.id) 
      @user.user_type_code = "AD"
      @user.uid = 0
      @user.save
      expect(Listing.get_by_seller(@user).count).to eq 2
    end
  end

  describe "buyer listings", main: true  do 
    before :each, run: true do
      create_invoice 'paid'
    end

    it { Listing.get_by_buyer(0).should_not include @listing } 
    it "includes buyer listings", run: true do 
      Listing.get_by_buyer(@invoice.buyer_id).should_not be_empty  
    end
  end

  describe "site", main: true  do 
    before :each, run: true do
      @listing.site_id = 100 
    end

    it { @listing.site_name.should_not be_empty } 
    it "should not find correct site name", run: true do 
      @listing.site_name.should be_nil 
    end

    it "should not return site count > 0", run: true do 
      @listing.get_site_count.should == 0  
    end
    it { @listing.get_site_count.should_not == 0 } 
  end

  describe 'primary_address', main: true do
    before :each, run: true do
      @listing.save!
    end

    it 'has primary address', run: true  do
      @contact = @listing.contacts.create FactoryGirl.attributes_for(:contact)
      expect(@listing.primary_address).to eq @contact.full_address
    end

    it 'has seller primary address' do
      seller = create :business_user
      listing = create :listing, seller_id: seller.id
      expect(listing.primary_address).to eq seller.primary_address
    end

    it 'has no primary address', run: true do
      expect(@listing.primary_address).to be_nil
    end
  end

  describe "should find correct category name", main: true  do 
    it { @listing.category_name.should == 'Foo Bar' } 
    it "should not find correct category name" do 
      @listing.category_id = 100 
      @listing.category_name.should be_nil  
    end
  end

  describe "seller flds", main: true  do 
    it { expect(@listing.seller_name).to eq(@user.name) } 
    it "does not find seller name" do 
      @listing.seller_id = 100 
      expect(@listing.seller_name).not_to eq(@user.name)
    end

    it { expect(@listing.seller_email).to eq(@user.email) } 
    it "does not find seller email" do 
      @listing.seller_id = 100 
      expect(@listing.seller_email).not_to eq(@user.email)
    end

    it { @listing.seller_photo.should_not be_nil } 
    it 'does not return seller photo' do 
      @listing.seller_id = 100 
      @listing.seller_photo.should be_nil  
    end

    it { @listing.seller_rating_count.should == 0 } 
    it 'returns seller rating count' do 
      @listing.save!
      @buyer = create(:pixi_user)
      @rating = @buyer.ratings.create FactoryGirl.attributes_for :rating, seller_id: @user.id, pixi_id: @listing.id
      expect(@listing.seller_rating_count).to eq(1)
    end

    it "checks if seller name is an alias" do 
      @listing.show_alias_flg = 'yes'
      expect(@listing.alias?).to be_true 
    end

    it "does not have an alias" do 
      @listing.show_alias_flg = 'no'
      expect(@listing.alias?).not_to be_true 
    end

    context "does not have a business seller" do
      it { expect(@listing.sold_by_business?).not_to be_true }
      it { expect(@listing.seller_address?).not_to be_true }
    end

    context 'has a business seller' do
      before :each do 
        @seller = create :business_user
        @listing2 = build :listing, seller_id: @seller.id, quantity: 2, title: 'Leather Coat'
      end
      it { expect(@listing2.sold_by_business?).to be_true }
      it { expect(@listing2.seller_address?).to be_true }
    end
  end

  describe 'any_locations?', main: true do
    it { expect(@listing.any_locations?).not_to be_true }
    it 'has locations' do
      @listing.contacts.build attributes_for :contact
      expect(@listing.any_locations?).to be_true
    end
  end

  describe "condition", main: true  do 
    before { create :condition_type, code: 'N' }
    it { expect(@listing.condition).to be_nil } 
    it "finds condition" do 
      @listing.condition_type_code = 'N' 
      expect(@listing.condition).not_to be_nil
    end
  end

  describe "transaction", main: true  do 
    before :each, run: true do
      @listing.transaction_id = nil
    end
    it { @listing.has_transaction?.should be_true }
    it 'has no txn', run: true do
      @listing.has_transaction?.should_not be_true
    end
  end

  describe "seller?", main: true  do 
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

  describe "pixter", main: true  do 
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

  describe "editable", main: true  do 
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

  describe "description methods", base: true   do 
    before { @listing.description = "a" * 100 }

    it "should return a short description" do 
      @listing.brief_descr.length.should == 100 
    end

    it "should return a summary" do 
      @listing.summary.should be_true 
    end

    it "should not return a short description of 100 chars" do 
      @listing.description = "a" 
      @listing.brief_descr.length.should_not == 100 
    end

    it "should not return a summary" do 
      @listing.description = nil
      @listing.summary.should_not be_true 
    end
  end

  describe "nice title", detail: true  do 
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

  describe "pixi_post", detail: true do 
    before :each, run: true do 
      @pixan = FactoryGirl.create(:contact_user) 
      @listing.pixan_id = @pixan.id 
    end
    it { @listing.pixi_post?.should_not be_true }
    it 'has a pixan', run: true do
      @listing.pixi_post?.should be_true
    end
  end

  describe "must have pictures", detail: true   do 
    let(:listing) { FactoryGirl.build :invalid_listing }
    it "should not save w/o at least one picture" do 
      listing.save
      listing.should_not be_valid 
    end
  end 
    
  describe "activate", detail: true do 
    let(:listing) { FactoryGirl.build :listing, start_date: Time.now, status: 'pending' }
    it { listing.activate.status.should == 'active' } 
    it 'does not activate' do
      listing.status = 'sold'
      listing.activate.status.should_not == 'active'
    end
  end

  describe 'pictures', base: true do
    before(:each) do
      @listing.save!
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

  describe 'contacts', base: true   do
    before(:each) do
      @listing.save
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

  describe 'check for free order', detail: true do
    it "should not allow free order" do 
      @pixi = FactoryGirl.create(:listing, seller_id: @user.id, site_id: 100) 
      stub_const("Listing::SITE_FREE_AMT", 0)
      expect(Listing::SITE_FREE_AMT).to eq(0)
      Listing.free_order?(@pixi.site_id).should_not be_true  
    end

    it "should allow free order" do 
      @listing.site_id = 2 
      @listing.save!
      Listing.free_order?(2).should be_true  
    end
  end  

  describe 'premium?', detail: true  do
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

  describe 'get invoice', detail: true do
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

  describe 'inactive?', detail: true  do
    it 'should return true' do
      @listing.status = 'inactive'
      @listing.inactive?.should be_true
    end

    it 'should not return true' do
      @listing.inactive?.should_not be_true
    end
  end

  describe 'mark_as_sold', process: true  do
    before :each, run: true do
      create_invoice 'paid'
    end

    it 'returns true', run: true do
      @listing.mark_as_sold.should be_true
    end

    it 'closes other invoices', run: true do
      @buyer2 = create :pixi_user
      @invoice2 = @user.invoices.build attributes_for(:invoice, buyer_id: @buyer2.id) 
      @details = @invoice2.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id, quantity: 1 
      @invoice2.save!
      @listing.mark_as_sold
      expect(@invoice2.reload.status).to eq 'closed'
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

  describe "comment associations", detail: true  do

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

  describe '.same_day?', date: true  do
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

  describe '.is_category_type?', detail: true  do
    it { check_cat_type(@listing, 'event').should be_false }
    it "is an category type" do
      check_cat_type(@listing, 'event', true).should be_true
      check_cat_type(@listing, ['service', 'sales', 'event'], true).should be_true
      check_cat_type(@listing, %w(service sales event), true).should be_true
    end
  end

  describe '.has_status?', detail: true  do
    it { @listing.has_status?('').should be_false }
    it "return true" do
      @listing.has_status?('active').should be_true
      @listing.has_status?(['sold', 'removed','active']).should be_true
    end
  end

  describe '.event?', detail: true  do
    it { @listing.event?.should be_false }
    it "is an event" do
      @cat = FactoryGirl.create(:category, name: 'Event', category_type_code: 'event', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      @listing.event?.should be_true
    end
  end

  describe '.has_year?', detail: true  do
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

  describe '.job?', detail: true  do
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

  describe '.start_date?', date: true  do
    it "has no start date" do
      @listing.start_date?.should be_false
    end

    it "has a start date" do
      @listing.event_start_date = Time.now
      @listing.start_date?.should be_true
    end
  end

  describe "saved", detail: true  do 
    before(:each) do
      @listing.save!
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

  describe "send_saved_pixi_removed", process: true  do
    before(:each) do
      @listing.save!
      @saved_listing = FactoryGirl.create(:saved_listing, user_id: @user.id, pixi_id: @listing.pixi_id)
    end

    it 'delivers the email' do
      @listing.status = 'sold'
      @listing.save; sleep 2
      expect(ActionMailer::Base.deliveries.last.subject).to include(@listing.title) 
    end

    it 'sends email to right user' do
      @listing.status = 'removed'
      @listing.save; sleep 2
      expect(ActionMailer::Base.deliveries.last.to).to eql([@saved_listing.user.email])
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

  describe "wanted", detail: true do 
    before(:each) do
      @usr = create :pixi_user
      @buyer = create :pixi_user
      @listing.save!
      @pixi_want = @buyer.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
      @pixi_want = @user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id, status: 'sold'
    end

    it { Listing.wanted_list(@usr, nil, nil, false).should_not include @listing } 
    it { Listing.wanted_list(@buyer, nil, nil, false).should_not be_empty }
    it { expect(@listing.wanted_count).to eq(1) }
    it { expect(@listing.is_wanted?).to eq(true) }

    it "is not wanted" do
      listing = create(:listing, seller_id: @user.id, title: 'Hair brush') 
      expect(listing.wanted_count).to eq(0)
      expect(listing.is_wanted?).to eq(false)
    end

    it { expect(Listing.wanted_users(@listing.pixi_id).first.name).to eq(@buyer.name) }
    it { expect(Listing.wanted_users(@listing.pixi_id)).not_to include(@usr) }
    it { expect(@listing.user_wanted?(@buyer)).not_to be_nil }
    it { expect(@listing.user_wanted?(@usr)).not_to eq(true) }

    it "shows all wanted pixis for admin" do
      expect(Listing.wanted_list(@admin_user, @listing.category_id, @listing.site_id).count).not_to eq 0
      Listing.wanted_list(@admin_user, @listing.category_id, @listing.site_id).should include @listing
      Listing.wanted_list(@usr, @listing.category_id, @listing.site_id, false).should_not include @listing
    end
  end

  describe "asked", detail: true  do 
    before(:each) do
      @usr = create :pixi_user
      @buyer = create :pixi_user
      @listing.save!
      @pixi_ask = @buyer.pixi_asks.create FactoryGirl.attributes_for :pixi_ask, pixi_id: @listing.pixi_id
    end

    it { Listing.asked_list(@usr).should_not include @listing } 
    it { Listing.asked_list(@buyer).should_not be_empty }
    it { expect(@listing.asked_count).to eq(1) }
    it { expect(@listing.is_asked?).to eq(true) }

    it "is not asked" do
      listing = create(:listing, seller_id: @user.id, title: 'Hair brush') 
      expect(listing.asked_count).to eq(0)
      expect(listing.is_asked?).to eq(false)
    end

    it { expect(Listing.asked_users(@listing.pixi_id).first.name).to eq(@buyer.name) }
    it { expect(Listing.asked_users(@listing.pixi_id)).not_to include(@usr) }
    it { expect(@listing.user_asked?(@buyer)).not_to be_nil }
    it { expect(@listing.user_asked?(@usr)).not_to eq(true) }
  end

  describe "cool", detail: true  do 
    before(:each) do
      @listing.save!
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

  describe 'msg count', detail: true do
    before(:each) do
      @listing.save!
    end

    it { expect(@listing.msg_count).to eq(0) }
    it "has messages" do
      @recipient = FactoryGirl.create :pixi_user
      @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id
      @post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, conversation_id: 
        @conversation.id, pixi_id: @listing.pixi_id
      expect(@listing.msg_count).to eq(1)
    end
  end

  describe "find_pixi", detail: true  do
    before(:each) do
      @listing.save!
    end
    it 'finds a pixi' do
      expect(Listing.find_pixi(@listing.pixi_id)).not_to be_nil
    end

    it 'does not find pixi' do
      expect(Listing.find_pixi(0)).to be_nil
    end
  end

  describe "dup pixi", process: true  do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it "does not return new listing" do 
      listing = FactoryGirl.build :listing, seller_id: user.id 
      dup_listing = listing.dup_pixi(false) rescue nil
      expect(dup_listing).to be_nil
    end

    it "returns new listing" do 
      new_pixi = listing.dup_pixi(false)
      expect(new_pixi.status).to eq('edit')
      expect(new_pixi.title).to eq(listing.title)
      expect(new_pixi.id).not_to eq(listing.id)
      expect(new_pixi.pictures.size).to eq(listing.pictures.size)
    end
  end

  describe "date display methods", date: true do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

    it "does not show start date" do
      listing.start_date = nil
      listing.start_date.should be_nil
    end

    it { listing.start_date.should_not be_nil }
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

  describe "sync saved pixis", process: true  do
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

  describe 'remove_item_list', detail: true do
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

  describe 'job_type_name', base: true  do
    it "shows description" do
      create :job_type
      @listing.job_type_code = 'CT'
      expect(@listing.job_type_name).to eq 'Contract'
    end

    it "does not show description" do
      expect(@listing.job_type_name).to be_nil
    end
  end

  describe "date validations", date: true do
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

  describe "close_pixis", process: true do
    before { @listing.save! }
    it "should not close pixi if end_date is invalid" do
      @listing.update_attribute(:end_date, nil)
      Listing.close_pixis
      @listing.reload.status.should_not == 'closed'
    end
    it "should not close pixi with an end_date >= today" do
      @listing.update_attribute(:end_date, Date.today + 1.days)
      Listing.close_pixis
      @listing.reload.status.should_not == 'closed'
    end
    it "should close pixi with an end_date < today" do
      @listing.update_attribute(:end_date, Date.today - 1.days)
      Listing.close_pixis
      @listing.reload.status.should == 'closed'
    end
  end

  describe '.event_type', base: true  do
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
  
  describe 'async_send_notifications', process: true  do

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
      expect(Listing.count).to eq 1
      send_mailer listing, 'send_approval'
      expect(Conversation.all.count).not_to eq(0)
      expect(Post.all.count).not_to eq(0)
      SystemMessenger.stub!(:send_system_message).with(@user, listing, 'repost').and_return(true)
    end
  end

  describe 'set_invoice_status', process: true  do
    before do 
      create_invoice 'unpaid', 1, false
    end

    it 'sets invoice status to removed' do
      expect {
        create(:saved_listing, user_id: @buyer.id, pixi_id: @listing.pixi_id); sleep 1
        @listing.update_attribute(:status, 'removed')
      }.to change{ Invoice.where(:status => 'removed').count }.by(1)
    end

    it 'does not set invoice status' do
      @invoice.update_attribute :status, 'paid'
      @listing.status = 'sold'
      @listing.save
      expect(@invoice.status).not_to eq 'closed'
    end
  end

  describe 'expired?', base: true do
    it 'should return true' do
      @listing.status = 'expired'
      @listing.expired?.should be_true
    end

    it 'should not return true' do
      @listing.expired?.should_not be_true
    end
  end

  describe 'repost', process: true  do
    before { @listing.save! }
    it 'sets status to active if listing is expired' do
      @listing.update_attribute(:status, 'expired')
      @listing.repost
      @listing.active?.should be_true
      expect(@listing.reload.repost_flg).to be_true
      expect(ActionMailer::Base.deliveries.last.subject).to include("Pixi Reposted: #{@listing.title} ") 
    end

    it 'sets status to active if listing is removed' do
      @listing.status = 'removed'
      @listing.explanation = 'Changed Mind'
      @listing.save
      @listing.repost
      @listing.active?.should be_true
      expect(@listing.reload.repost_flg).to be_true
      expect(@listing.explanation).to be_nil
      expect(ActionMailer::Base.deliveries.last.subject).to include("Pixi Reposted: #{@listing.title} ") 
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

  describe 'soon_expiring_pixis', process: true  do
    before { @listing.save! }
    it "includes active listings" do 
      update_pixi @listing, 'active', 4
    end
	
    it "includes expired listings" do
      update_pixi @listing, 'expired', 4
      Listing.soon_expiring_pixis(4, 'expired').should_not be_empty  
    end
	
    it "includes expired listings" do
      update_pixi @listing, 'expired', 4
      Listing.soon_expiring_pixis(4, ['expired', 'active']).should_not be_empty  
    end
	
    it "includes active listings" do
      update_pixi @listing, 'active', 5
      Listing.soon_expiring_pixis(5, ['expired', 'active']).should_not be_empty  
    end
	
    it "includes default active listings" do
      update_pixi @listing, 'active', 7
      Listing.soon_expiring_pixis().should_not be_empty  
    end
  end
  
  describe 'not soon_expiring_pixis', process: true  do  
    it "does not include active listings" do 
      update_pixi @listing, 'active', 10
      Listing.soon_expiring_pixis(8).should be_empty  
    end
	
    it "does not include expired listings" do 
      update_pixi @listing, 'expired', 4
      Listing.soon_expiring_pixis(3).should be_empty  
    end
	
    it "does not include expiring early listings" do 
      update_pixi @listing, 'expired', 4
      Listing.soon_expiring_pixis(5).should be_empty  
    end
	
    it "does not include active listings" do 
      update_pixi @listing, 'active', 4
      Listing.soon_expiring_pixis(5, nil).should be_empty  
    end
	
    it "does not include active listings" do 
      update_pixi @listing, ['expired', 'new'], 5
      Listing.soon_expiring_pixis(5, ['expired', 'new']).should be_empty  
    end
  end

  describe "sold count", process: true  do
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

  describe "amt left", process: true  do
    before :each, run: true do
      @listing.update_attribute(:quantity, 3)
      create_invoice 'paid'
    end
    it { expect(@listing.amt_left).to eq 1 }
    it "has count > 1", run: true do
      expect(@listing.amt_left).not_to eq 1
    end
  end

  describe "get_by_city", process: true  do
    before { @listing.save! }
    it { Listing.get_by_city(0, 1).should_not include @listing } 
    it "should be able to toggle get_active" do
      @site = create :site, org_type: 'city', name: 'SF'
      @site.contacts.create(FactoryGirl.attributes_for(:contact, address: '101 California', city: 'SF', state: 'CA', zip: '94111'))
      @listing.update_attribute(:site_id, @site.id)
      Listing.get_by_city(@listing.category_id, @listing.site_id, true).should_not be_empty
      Listing.get_by_city(@listing.category_id, @listing.site_id, false).should be_empty
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

  describe "invoiceless pixis", process: true  do
    before do
      @listing.save!
      @pixi_want = @user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
      @pixi_want.created_at = 3.days.ago
      @pixi_want.save!
    end

    it "toggles number_of_days" do
      Listing.invoiceless_pixis.should include @listing
      Listing.invoiceless_pixis(5).should_not include @listing
    end

    it "does not return pixis with wants less than two days old" do
      @pixi_want.created_at = Time.now
      @pixi_want.save!
      Listing.invoiceless_pixis.should_not include @listing
    end

    it "returns invoiced pixis in job category" do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'employment', pixi_type: 'premium') 
      @listing.category_id = Category.find_by_name("Jobs").id
      @listing.job_type_code = 'FT'
      @listing.save!
      create_invoice
      Listing.invoiceless_pixis.should include @listing
    end

    it "returns invoiced pixis with no price" do
      @listing.price = nil
      @listing.save!
      create_invoice
      Listing.invoiceless_pixis.should include @listing
    end

    it "does not return other pixis with invoices" do
      create_invoice
      Listing.invoiceless_pixis.should_not include @listing
    end
  end

  describe "purchased", process: true  do 
    before :each, run: true do
      create_invoice 'paid', 2
    end

    it { Listing.purchased(@user).should_not include @listing } 
    it "includes buyer listings", run: true do 
      expect(Listing.purchased(@invoice.buyer).size).to eq 2
    end
  end

  describe "sold_list", process: true  do 
    before :each, run: true do
      create_invoice 'paid', 2
    end

    it { Listing.sold_list.should_not include @listing } 
    it "includes sold listings", run: true do 
      @listing.save
      expect(Listing.sold_list.size).to eq 2
    end
  end

  describe 'update_counter_cache', process: true do
    it "updates cache on create" do
      @listing.save!
      expect(@user.reload.active_listings_count).to eq 1
    end
    it "zeroes cache on non-active status" do
      listing = FactoryGirl.create(:listing, seller_id: @user.id, quantity: 1, status: 'active') 
      listing.update_attribute(:status, 'inactive')
      expect(Listing.active.size).to eq 0
      expect(User.find(@listing.seller_id).active_listings_count).to eq 0
    end
    it "resets cache on update" do
      listing = FactoryGirl.create(:listing, seller_id: @user.id, quantity: 1, status: 'inactive') 
      listing.update_attribute(:status, 'active')
      expect(@user.reload.active_listings_count).to eq 1
    end
  end
end
