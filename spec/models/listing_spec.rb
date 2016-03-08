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
    it { is_expected.to respond_to(:title) }
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:site_id) }
    it { is_expected.to respond_to(:seller_id) }
    it { is_expected.to respond_to(:alias_name) }
    it { is_expected.to respond_to(:transaction_id) }
    it { is_expected.to respond_to(:show_alias_flg) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:price) }
    it { is_expected.to respond_to(:start_date) }
    it { is_expected.to respond_to(:end_date) }
    it { is_expected.to respond_to(:buyer_id) }
    it { is_expected.to respond_to(:show_phone_flg) }
    it { is_expected.to respond_to(:category_id) }
    it { is_expected.to respond_to(:pixi_id) }
    it { is_expected.to respond_to(:parent_pixi_id) }
    it { is_expected.to respond_to(:post_ip) }
    it { is_expected.to respond_to(:event_start_date) }
    it { is_expected.to respond_to(:event_end_date) }
    it { is_expected.to respond_to(:compensation) }
    it { is_expected.to respond_to(:lng) }
    it { is_expected.to respond_to(:lat) }
    it { is_expected.to respond_to(:event_start_time) }
    it { is_expected.to respond_to(:event_end_time) }
    it { is_expected.to respond_to(:year_built) }
    it { is_expected.to respond_to(:pixan_id) }
    it { is_expected.to respond_to(:job_type_code) }
    it { is_expected.to respond_to(:event_type_code) }
    it { is_expected.to respond_to(:explanation) }
    it { is_expected.to respond_to(:repost_flg) }
    it { is_expected.to respond_to(:quantity) }
    it { is_expected.to respond_to(:condition_type_code) }
    it { is_expected.to respond_to(:color) }
    it { is_expected.to respond_to(:other_id) }
    it { is_expected.to respond_to(:mileage) }
    it { is_expected.to respond_to(:item_type) }
    it { is_expected.to respond_to(:item_size) }
    it { is_expected.to respond_to(:bed_no) }
    it { is_expected.to respond_to(:bath_no) }
    it { is_expected.to respond_to(:term) }
    it { is_expected.to respond_to(:avail_date) }

    it { is_expected.to respond_to(:user) }
    it { is_expected.to respond_to(:site) }
    it { is_expected.to respond_to(:posts) }
    it { is_expected.to respond_to(:conversations) }
    it { is_expected.to respond_to(:invoices) }
    #it { should respond_to(:site_listings) }
    it { is_expected.to respond_to(:transaction) }
    it { is_expected.to respond_to(:pictures) }
    it { is_expected.to respond_to(:contacts) }
    it { is_expected.to respond_to(:category) }
    it { is_expected.to respond_to(:job_type) }
    it { is_expected.to respond_to(:event_type) }
    it { is_expected.to belong_to(:event_type).with_foreign_key('event_type_code') }
    it { is_expected.to respond_to(:condition_type) }
    it { is_expected.to belong_to(:condition_type).with_foreign_key('condition_type_code') }
    it { is_expected.to respond_to(:comments) }
    it { is_expected.to respond_to(:pixi_likes) }
    it { is_expected.to have_many(:pixi_likes).with_foreign_key('pixi_id') }
    it { is_expected.to respond_to(:pixi_wants) }
    it { is_expected.to have_many(:pixi_wants).with_foreign_key('pixi_id') }
    it { is_expected.to respond_to(:saved_listings) }
    it { is_expected.to have_many(:saved_listings).with_foreign_key('pixi_id')}
    it { is_expected.to have_many(:active_saved_listings).with_foreign_key('pixi_id').conditions(:status=>"active") }
    it { is_expected.to respond_to(:buyer) }
    it { is_expected.to belong_to(:buyer).with_foreign_key('buyer_id') }
    it { is_expected.to have_many(:active_pixi_wants).class_name('PixiWant').with_foreign_key('pixi_id').conditions(:status=>"active") }
    it { is_expected.to accept_nested_attributes_for(:contacts).allow_destroy(true) }
    it { is_expected.to respond_to(:buy_now_flg) }
    it { is_expected.to respond_to(:est_ship_cost) }
    it { is_expected.to respond_to(:sales_tax) }
    it { is_expected.to respond_to(:fulfillment_type_code) }
    it { is_expected.to belong_to(:fulfillment_type).with_foreign_key('fulfillment_type_code') }
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
    it { is_expected.to allow_value('chair').for(:title) }
    it { is_expected.not_to allow_value("a"*81).for(:title) }
    it { is_expected.not_to allow_value("").for(:title) }
    it { is_expected.to allow_value('chair').for(:description) }
    it { is_expected.not_to allow_value("").for(:description) }

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
      expect(Listing.active).not_to eq(@listing) 
    end

    it "active page should not include inactive listings" do
      expect(Listing.active_page(1)).not_to eq(@listing) 
    end

    it "get_by_status orders by updated_at DESC" do
      @listing.update_attribute(:status, 'expired')
      @listing2 = FactoryGirl.build(:listing, seller_id: @user.id, quantity: 1)
      @listing2.pictures.build(FactoryGirl.attributes_for :picture)
      @listing2.save!
      @listing2.update_attribute(:status, 'expired')
      result = Listing.get_by_status('expired')
      expect(result.first.created_date.to_s).to eq @listing2.updated_at.to_s
      expect(result.last.created_date.to_s).to eq @listing.updated_at.to_s
    end

    it "get_by_status should not include inactive listings" do
      expect(Listing.get_by_status('active')).not_to eq(@listing) 
    end
  end

  describe "includes active listings", base: true  do 
    before { @listing.save! }
    it { expect(Listing.active).to be_truthy }
    it { expect(Listing.active_page(1)).to be_truthy }
    it { expect(Listing.get_by_status('active').count(:all)).not_to eq 0 }
    it 'orders by end_date ASC' do
      @listing2 = FactoryGirl.build(:listing, seller_id: @user.id, quantity: 1, status: 'active', end_date: @listing.end_date + 7.days)
      @listing2.pictures.build(FactoryGirl.attributes_for :picture)
      @listing2.save!
      result = Listing.get_by_status('active')
      expect(result.first.created_date).to eq @listing.end_date
      expect(result.first.created_date).to eq @listing2.end_date
    end
  end

  describe "site listings", base: true  do 
    before { @listing.save! }
    it { expect(Listing.get_by_site(0)).not_to include @listing } 
    it { expect(Listing.get_by_site(@listing.site.id).count(:all)).not_to eq 0 }
  end

  describe "category listings", base: true   do 
    it { expect(Listing.get_by_category(0)).not_to include @listing } 
    it 'finds listing by category' do
      @listing.save!
      expect(Listing.get_by_category(@listing.category_id).count(:all)).not_to eq 0
    end
  end

  describe "active_invoices", main: true  do
    it 'should not get listings if none are invoiced' do
      @listing.status = 'active'
      @listing.save
      expect(Listing.active.count(:all)).not_to eq 0
      expect(Listing.active_invoices.count(:all)).to eq 0
    end

    it 'should get listings' do
      create_invoice "unpaid"
      expect(Listing.active_invoices.count(:all)).not_to eq 0
    end
  end

  describe "check_category_and_location", main: true  do
    before { @listing.save! }
    it "should get all listings of given status if category and location are not specified" do
      expect(Listing.check_category_and_location('active', nil, nil, true).count(:all)).not_to eq 0
    end

    it "should get listing when category and location are specified" do      
      expect(Listing.check_category_and_location('active', @listing.category_id, @listing.site_id, true).count(:all)).not_to eq 0
    end

    it "should not return anything if no listings meet the parameters" do
      expect(Listing.check_category_and_location('removed', 100, 900, true).count(:all)).to eq 0
    end

    it "only returns necessary attributes" do
      listing = Listing.check_category_and_location('active', nil, nil, true).first
      expect(listing.attributes.keys).to include 'title'
      expect(listing.attributes.keys).not_to include 'color'
    end
  end

  describe "check_invoiced_category_and_location", main: true  do
    before do
      @listing.save!
      create_invoice "unpaid"
    end      

    it "should get all listings of given status if category and location are not specified" do
      expect(Listing.check_invoiced_category_and_location(nil, nil).count(:all)).not_to eq 0
    end

    it "should get listing when category and location are specified" do      
      expect(Listing.check_invoiced_category_and_location(@listing.category_id, @listing.site_id).count(:all)).not_to eq 0
    end

    it "should not return anything if no listings meet the parameters" do
      expect(Listing.check_invoiced_category_and_location(100, 900).count(:all)).to eq 0
    end

    it "only returns necessary attributes" do
      expect(Listing.check_invoiced_category_and_location(nil, nil).last.title).to eq @listing.title
      expect(Listing.check_invoiced_category_and_location(nil, nil).last.attributes[:color]).to be_nil
    end
  end

  describe "has_enough_pixis?", main: true  do
    before { @listing.save! }
    it "returns true" do
      stub_const("MIN_PIXI_COUNT", 0)
      expect(MIN_PIXI_COUNT).to eq(0)
      expect(Listing.has_enough_pixis?(@listing.category_id, @listing.site_id)).to be_truthy
    end

    it "returns false" do
      stub_const("MIN_PIXI_COUNT", 500)
      expect(MIN_PIXI_COUNT).to eq(500)
      expect(Listing.has_enough_pixis?(@listing.category_id, 1)).not_to be_truthy
    end
  end

  describe "seller listings", main: true  do 
    it "includes seller listings" do 
      @listing.seller_id = 1
      @listing.save
      @user.uid = 1
      @user.save
      expect(Listing.get_by_seller(@user, 'active', false).count(:all)).not_to eq 0
    end

    it "does not get all listings for non-admin" do
      @listing.seller_id = 100
      @listing.save
      expect(Listing.get_by_seller(@user, 'active', false)).not_to include @listing
    end

    it "gets all listings for admin" do
      @listing.save
      @other = FactoryGirl.create(:pixi_user)
      listing = FactoryGirl.create(:listing, seller_id: @other.id) 
      @user.user_type_code = "AD"
      @user.uid = 0
      @user.save
      expect(Listing.get_by_seller(@user, 'active').count).to eq 2
    end
  end

  describe "buyer listings", main: true  do 
    before :each, run: true do
      create_invoice 'paid'
    end

    it { expect(Listing.get_by_buyer(0)).not_to include @listing } 
    it "includes buyer listings", run: true do 
      expect(Listing.get_by_buyer(@invoice.buyer_id).count(:all)).not_to eq 0
    end
  end

  describe "site", main: true  do 
    before :each, run: true do
      @listing.site_id = 100 
    end

    it { expect(@listing.site_name).not_to be_empty } 
    it "should not find correct site name", run: true do 
      expect(@listing.site_name).to be_nil 
    end

    it "should not return site count > 0", run: true do 
      expect(@listing.get_site_count).to eq(0)  
    end
    it { expect(@listing.get_site_count).not_to eq(0) } 
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
    it { expect(@listing.category_name).to eq('Foo Bar') } 
    it "should not find correct category name" do 
      @listing.category_id = 100 
      expect(@listing.category_name).to be_nil  
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

    context "seller_first_name" do
      it { expect(@listing.seller_first_name).to eq(@user.first_name) } 
      it "does not find seller first_name" do 
        @listing.seller_id = 100 
        expect(@listing.seller_first_name).not_to eq(@user.first_name)
      end
    end

    context "seller_url" do
      it { expect(@listing.seller_url).to eq(['http:',@user.user_url].join('//')) } 
      it "does not find seller url" do 
        @listing.seller_id = 100 
        expect(@listing.seller_url).not_to eq(@user.user_url)
      end
    end

    it { expect(@listing.seller_photo).not_to be_nil } 
    it 'does not return seller photo' do 
      @listing.seller_id = 100 
      expect(@listing.seller_photo).to be_nil  
    end

    it { expect(@listing.seller_rating_count).to eq(0) } 
    it 'returns seller rating count' do 
      @listing.save!
      @buyer = create(:pixi_user)
      @rating = @buyer.ratings.create FactoryGirl.attributes_for :rating, seller_id: @user.id, pixi_id: @listing.id
      expect(@listing.seller_rating_count).to eq(1)
    end

    it "checks if seller name is an alias" do 
      @listing.show_alias_flg = 'yes'
      expect(@listing.alias?).to be_truthy 
    end

    it "does not have an alias" do 
      @listing.show_alias_flg = 'no'
      expect(@listing.alias?).not_to be_truthy 
    end

    context "does not have a business seller" do
      it { expect(@listing.sold_by_business?).not_to be_truthy }
      it { expect(@listing.seller_address?).not_to be_truthy }
    end

    context 'has a business seller' do
      before :each do 
        @seller = create :business_user
        @listing2 = build :listing, seller_id: @seller.id, quantity: 2, title: 'Leather Coat'
      end
      it { expect(@listing2.sold_by_business?).to be_truthy }
      it { expect(@listing2.seller_address?).to be_truthy }
    end
  end

  describe 'any_locations?', main: true do
    it { expect(@listing.any_locations?).not_to be_truthy }
    it 'has locations' do
      @listing.contacts.build attributes_for :contact
      expect(@listing.any_locations?).to be_truthy
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
    it { expect(@listing.has_transaction?).to be_truthy }
    it 'has no txn', run: true do
      expect(@listing.has_transaction?).not_to be_truthy
    end
  end

  describe "seller?", main: true  do 
    before do
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
    end

    it "should verify user is seller" do 
      expect(@listing.seller?(@user)).to be_truthy 
    end

    it  "should not verify user is seller" do 
      expect(@listing.seller?(@user2)).not_to be_truthy 
    end
  end

  describe "pixter", main: true  do 
    before do
      @pixter = create :pixi_user, user_type_code: 'PT'
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
      @listing = FactoryGirl.create(:listing, seller_id: @user.id, pixan_id: @pixter.id) 
    end

    it "should verify user is pixter" do 
      expect(@listing.pixter?(@pixter)).to be_truthy 
    end

    it "should not verify user is pixter" do 
      expect(@listing.pixter?(@user2)).not_to be_truthy 
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
      expect(@listing.editable?(@pixter)).to be_truthy 
      expect(@listing.editable?(@user)).to be_truthy 
      expect(@listing.editable?(@admin)).to be_truthy 
      expect(@listing.editable?(@support)).to be_truthy 
    end

    it "is not editable" do 
      expect(@listing.editable?(@user2)).not_to be_truthy 
    end
  end

  describe "description methods", base: true   do 
    before { @listing.description = "a" * 100 }

    it "should return a short description" do 
      expect(@listing.brief_descr.length).to eq(100) 
    end

    it "should return a summary" do 
      expect(@listing.summary).to be_truthy 
    end

    it "should not return a short description of 100 chars" do 
      @listing.description = "a" 
      expect(@listing.brief_descr.length).not_to eq(100) 
    end

    it "should not return a summary" do 
      @listing.description = nil
      expect(@listing.summary).not_to be_truthy 
    end
  end

  describe "nice title", detail: true  do 
    it "should return a nice title" do 
      expect(@listing.nice_title).to be_truthy 
    end

    it "should not return a nice title" do 
      @listing.title = nil
      expect(@listing.nice_title).not_to be_truthy 
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
    it { expect(@listing.pixi_post?).not_to be_truthy }
    it 'has a pixan', run: true do
      expect(@listing.pixi_post?).to be_truthy
    end
  end

  describe "must have pictures", detail: true   do 
    let(:listing) { FactoryGirl.build :invalid_listing }
    it "should not save w/o at least one picture" do 
      listing.save
      expect(listing).not_to be_valid 
    end
  end 
    
  describe "activate", detail: true do 
    let(:listing) { FactoryGirl.build :listing, start_date: Time.now, status: 'pending', end_date: Date.today-3.months }
    it { expect(listing.activate.status).to eq('active') } 
    it { expect(listing.activate.end_date).to be > Date.today }
    it 'does not activate' do
      listing.status = 'sold'
      expect(listing.activate.status).not_to eq('active')
    end
  end

  describe 'pictures', base: true do
    before(:each) do
      @listing.save!
      @sr = @listing.pictures.create FactoryGirl.attributes_for(:picture)
    end
				            
    it "should have many pictures" do 
      expect(@listing.pictures).to include(@sr)
    end

    it "should destroy associated pictures" do
      @listing.destroy
      [@sr].each do |s|
         expect(Picture.find_by_id(s.id)).to be_nil
       end
    end  
  end  

  describe 'contacts', base: true   do
    before(:each) do
      @listing.save
      @sr = @listing.contacts.create FactoryGirl.attributes_for(:contact)
    end
				            
    it "should have many contacts" do 
      expect(@listing.contacts).to include(@sr)
    end

    it "should destroy associated contacts" do
      @listing.destroy
      [@sr].each do |s|
         expect(Contact.find_by_id(s.id)).to be_nil
       end
    end  
  end  

  describe 'check for free order', detail: true do
    it "should not allow free order" do 
      @pixi = FactoryGirl.create(:listing, seller_id: @user.id, site_id: 100) 
      stub_const("Listing::SITE_FREE_AMT", 0)
      expect(Listing::SITE_FREE_AMT).to eq(0)
      expect(Listing.free_order?(@pixi.site_id)).not_to be_truthy  
    end

    it "should allow free order" do 
      @listing.site_id = 2 
      @listing.save!
      expect(Listing.free_order?(2)).to be_truthy  
    end
  end  

  describe 'premium?', detail: true  do
    it 'should return true' do
      @listing.category_id = @category.id 
      expect(@listing.premium?).to be_truthy
    end

    it 'should not return true' do
      category = FactoryGirl.create(:category)
      @listing.category_id = category.id
      expect(@listing.premium?).not_to be_truthy
    end
  end

  describe 'get invoice', detail: true do
    before do 
      create_invoice
    end

    it 'should return true' do
      expect(@listing.get_invoice(@invoice.id)).to be_truthy
    end

    it 'should not return true' do
      expect(@listing.get_invoice(0)).not_to be_truthy
    end
  end

  describe 'inactive?', detail: true  do
    it 'should return true' do
      @listing.status = 'inactive'
      expect(@listing.inactive?).to be_truthy
    end

    it 'should not return true' do
      expect(@listing.inactive?).not_to be_truthy
    end
  end

  describe 'mark_as_sold', process: true  do
    before :each, run: true do
      create_invoice 'paid'
    end

    it 'returns true', run: true do
      expect(@listing.mark_as_sold).to be_truthy
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
      expect(@listing.mark_as_sold).not_to be_truthy
    end

    it 'does not mark when already sold' do
      @listing.status = 'sold'
      expect(@listing.mark_as_sold).not_to be_truthy
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
      expect(@listing.comments).to eq([newer_comment, older_comment])
    end

    it "should destroy associated comments" do
      comments = []
      @listing.comments.each { |comment| comments.push(comment) }
      @listing.destroy
      expect(comments).not_to be_empty

      comments.each do |comment|
        expect(Comment.find_by_id(comment.id)).to be_nil
      end
    end
  end

  describe '.same_day?', date: true  do
    before do
      @cat = FactoryGirl.create(:category, name: 'Events', pixi_type: 'premium') 
      @listing.category_id = @cat.id
    end

    it "should respond to same_day? method" do
      expect(@listing).to respond_to(:same_day?)
    end

    it "should be the same day" do
      @listing.event_start_date = Date.today
      @listing.event_end_date = Date.today
      expect(@listing.same_day?).to be_truthy
    end

    it "should not be the same day" do
      @listing.event_start_date = Date.today
      @listing.event_end_date = Date.today+1.day
      expect(@listing.same_day?).to be_falsey 
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
    it { expect(check_cat_type(@listing, 'event')).to be_falsey }
    it "is an category type" do
      expect(check_cat_type(@listing, 'event', true)).to be_truthy
      expect(check_cat_type(@listing, ['service', 'sales', 'event'], true)).to be_truthy
      expect(check_cat_type(@listing, %w(service sales event), true)).to be_truthy
    end
  end

  describe '.has_status?', detail: true  do
    it { expect(@listing.has_status?('')).to be_falsey }
    it "return true" do
      expect(@listing.has_status?('active')).to be_truthy
      expect(@listing.has_status?(['sold', 'removed','active'])).to be_truthy
    end
  end

  describe '.event?', detail: true  do
    it { expect(@listing.event?).to be_falsey }
    it "is an event" do
      @cat = FactoryGirl.create(:category, name: 'Event', category_type_code: 'event', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      expect(@listing.event?).to be_truthy
    end
  end

  describe '.has_year?', detail: true  do
    it { expect(@listing.has_year?).to be_falsey }

    it "when it's an asset" do
      @cat = FactoryGirl.create(:category, name: 'Homes', category_type_code: 'asset', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      expect(@listing.has_year?).to be_truthy 
    end

    it "when it's an vehicle" do
      @cat = FactoryGirl.create(:category, name: 'Homes', category_type_code: 'vehicle', pixi_type: 'premium') 
      @listing.category_id = @cat.id
      expect(@listing.has_year?).to be_truthy 
    end
  end

  describe '.job?', detail: true  do
    before :each, run: true do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'employment', pixi_type: 'premium') 
    end

    it "is not a job" do
      expect(@listing.job?).to be_falsey 
    end

    it "is a job", run: true do
      @listing.category_id = @cat.id
      expect(@listing.job?).to be_truthy 
    end

    it "is not valid", run: true  do
      @listing.category_id = @cat.id
      expect(@listing).not_to be_valid
    end

    it "is valid", run: true do
      create :job_type
      @listing.category_id = @cat.id
      @listing.job_type_code = 'CT'
      expect(@listing).to be_valid
    end
  end

  describe '.start_date?', date: true  do
    it "has no start date" do
      expect(@listing.start_date?).to be_falsey
    end

    it "has a start date" do
      @listing.event_start_date = Time.now
      expect(@listing.start_date?).to be_truthy
    end
  end

  describe "saved", detail: true  do 
    before(:each) do
      @listing.save!
      @usr = FactoryGirl.create :pixi_user
      @saved_listing = @user.saved_listings.create FactoryGirl.attributes_for :saved_listing, pixi_id: @listing.pixi_id
      @usr.saved_listings.create FactoryGirl.attributes_for :saved_listing, pixi_id: @listing.pixi_id, status: 'sold'
    end

    it { expect(Listing.saved_list(@user).first.created_date.to_s).to eq @saved_listing.created_at.to_s }
    it "checks saved list" do
      expect(Listing.saved_list(@usr)).not_to include @listing  
      expect(Listing.saved_list(@user)).not_to be_empty 
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

    it "only returns necessary attributes" do
      expect(Listing.saved_list(@user).first.title).to eq @listing.title
      expect(Listing.saved_list(@user).first.attributes[:color]).to be_nil
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
      @pixi_want = @usr.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id, status: 'sold'
      @pixi_want = @buyer.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
    end

    it { expect(Listing.wanted_list(@user, nil, nil, false)).not_to include @listing } 
    it { expect(Listing.wanted_list(@usr, nil, nil, false)).not_to include @listing } 
    it { expect(Listing.wanted_list(@buyer, nil, nil, false).count(:all)).not_to eq 0 }
    it { expect(@listing.wanted_count).to eq(1) }
    it { expect(@listing.is_wanted?).to eq(true) }
    it { expect(Listing.wanted_list(@buyer, nil, nil, false).first.created_date.to_s).to eq(@pixi_want.updated_at.to_s) }

    context 'seller wanted' do
      before :each do
        @seller = create :pixi_user
	@listing2 = create(:listing, seller_id: @seller.id, title: 'Hair brush')
	@want = @user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing2.pixi_id
      end
      it { expect(Listing.wanted_list(@user, nil, nil, false).count(:all)).not_to eq 0 } 
    end

    it "only returns necessary attributes" do
      expect(Listing.wanted_list(@buyer, nil, nil, false).first.title).to eq(@listing.title)
      expect(Listing.wanted_list(@buyer, nil, nil, false).first.attributes[:color]).to be_nil
    end

    it "is not wanted" do
      listing = create(:listing, seller_id: @user.id, title: 'Hair brush') 
      expect(listing.wanted_count).to eq(0)
      expect(listing.is_wanted?).to eq(false)
    end

    it { expect(Listing.wanted_users(@listing.pixi_id).map(&:name)).to include(@buyer.name) }
    it { expect(Listing.wanted_users(@listing.pixi_id)).not_to include(@usr) }
    it { expect(@listing.user_wanted?(@buyer)).not_to be_nil }
    it { expect(@listing.user_wanted?(@usr)).not_to eq(true) }

    it "shows all wanted pixis for admin" do
      expect(Listing.wanted_list(@admin_user, @listing.category_id, @listing.site_id).count(:all)).not_to eq 0
      expect(Listing.wanted_list(@admin_user, @listing.category_id, @listing.site_id)).to include @listing
      expect(Listing.wanted_list(@usr, @listing.category_id, @listing.site_id, false)).not_to include @listing
    end
  end

  describe "asked", detail: true  do 
    before(:each) do
      @usr = create :pixi_user
      @buyer = create :pixi_user
      @listing.save!
      @pixi_ask = @buyer.pixi_asks.create FactoryGirl.attributes_for :pixi_ask, pixi_id: @listing.pixi_id
    end

    it { expect(Listing.asked_list(@usr)).not_to include @listing } 
    it { expect(Listing.asked_list(@buyer)).not_to be_empty }
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

    it { expect(Listing.cool_list(@usr)).not_to include @listing } 
    it { expect(Listing.cool_list(@user)).not_to be_empty }
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
      expect(Listing.find_pixi(1)).to be_nil
    end
  end

  describe "dup pixi", process: true  do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }

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
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id, lat: 1.0, lng: 1.0 }

    it "does not show start date" do
      listing.start_date = nil
      expect(listing.start_date).to be_nil
    end

    it { expect(listing.start_date).not_to be_nil }
    it "does not show local updated date" do
      listing.updated_at = nil
      expect(listing.format_date(listing.updated_at)).to be_nil
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
        expect(@listing).to be_valid
      end

      it "should reject a bad start date" do
        @listing.event_start_date = Date.today-2.days
        expect(@listing).not_to be_valid
      end

      it "should not be valid without a start date" do
        @listing.event_start_date = nil
        expect(@listing).not_to be_valid
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
        expect(@listing).to be_valid
      end

      it "should reject a bad end date" do
        @listing.event_end_date = ''
        expect(@listing).not_to be_valid
      end

      it "should reject end date < start date" do
        @listing.event_end_date = Date.today-2.days
        expect(@listing).not_to be_valid
      end

      it "should not be valid without a end date" do
        @listing.event_end_date = nil
        expect(@listing).not_to be_valid
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
        expect(@listing).to be_valid
      end

      it "should reject a bad start time" do
        @listing.event_start_time = ''
        expect(@listing).not_to be_valid
      end

      it "should not be valid without a start time" do
        @listing.event_start_time = nil
        expect(@listing).not_to be_valid
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
        expect(@listing).to be_valid
      end

      it "should reject a bad end time" do
        @listing.event_end_time = ''
        expect(@listing).not_to be_valid
      end

      it "should reject end time < start time" do
        @listing.event_end_date = @listing.event_start_date
        @listing.event_end_time = Time.now.advance(:hours => -2)
        expect(@listing).not_to be_valid
      end

      it "should not be valid without a end time" do
        @listing.event_end_time = nil
        expect(@listing).not_to be_valid
      end
    end
  end

  describe "close_pixis", process: true do
    before { @listing.save! }
    it "should not close pixi if end_date is invalid" do
      @listing.update_attribute(:end_date, nil)
      Listing.close_pixis
      expect(@listing.reload.status).not_to eq('expired')
    end
    it "should not close pixi with an end_date >= today" do
      @listing.update_attribute(:end_date, Date.today + 1.days)
      Listing.close_pixis
      expect(@listing.reload.status).not_to eq('expired')
    end
    it "should close pixi with an end_date < today" do
      @listing.update_attribute(:end_date, Date.today - 1.days)
      Listing.close_pixis
      expect(@listing.reload.status).to eq('expired')
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
      expect(@listing1.event?).to be_truthy
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
      expect(@user.user_pixi_points.find_by_code('abp').code).to eq('abp')
      expect(@user.user_pixi_points.find_by_code('app')).to be_nil
    end

    it 'adds app pixi points' do
      @category = create(:category, pixi_type: 'premium')
      create(:listing, category_id: @category.id, seller_id: @user.id)
      expect(@user.user_pixi_points.count).not_to eq(0)
      expect(@user.user_pixi_points.find_by_code('app').code).to eq('app')
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
      allow(SystemMessenger).to receive(:send_system_message).with(@user, listing, 'approve').and_return(true)
    end

    it 'delivers reposted pixi message' do
      create :admin, email: PIXI_EMAIL
      listing = create(:listing, seller_id: @user.id, repost_flg: true)
      expect(Listing.count).to eq 1
      send_mailer listing, 'send_approval'
      expect(Conversation.all.count).not_to eq(0)
      expect(Post.all.count).not_to eq(0)
      allow(SystemMessenger).to receive(:send_system_message).with(@user, listing, 'repost').and_return(true)
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
      expect(@listing.expired?).to be_truthy
    end

    it 'should not return true' do
      expect(@listing.expired?).not_to be_truthy
    end
  end

  describe 'repost', process: true  do
    before { @listing.save! }
    it 'sets status to active if listing is expired' do
      @listing.update_attribute(:status, 'expired')
      @listing.update_attribute(:end_date, 100.days.ago)
      expect { @listing.repost }.to change { @listing.end_date }
      expect(@listing.active?).to be_truthy
      expect(@listing.end_date).to be > Date.today
      expect(@listing.reload.repost_flg).to be_truthy
      expect(ActionMailer::Base.deliveries.last.subject).to include("Pixi Reposted: #{@listing.title} ") 
    end

    it 'sets status to active if listing is removed' do
      @listing.status = 'removed'
      @listing.explanation = 'Changed Mind'
      @listing.end_date = 5.days.ago
      @listing.save!
      expect { @listing.repost }.to change { @listing.end_date }
      expect(@listing.active?).to be_truthy
      expect(@listing.reload.repost_flg).to be_truthy
      expect(@listing.explanation).to be_nil
      expect(ActionMailer::Base.deliveries.last.subject).to include("Pixi Reposted: #{@listing.title} ") 
    end

    it 'calls repost_pixi if listing is sold' do
      @listing.status = 'sold'
      picture = @listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo0.jpg")
      @listing.end_date = 5.days.ago
      @listing.save!
      expect(@listing.repost).to be_truthy
      expect(Listing.all.count(:all)).to eq 2
      expect(Listing.last.active?).to be_truthy
      expect(Listing.last.pictures.size).to eq @listing.pictures.size
      expect(Listing.last.repost_flg).to be_truthy
      expect(Listing.last.end_date).not_to eq @listing.end_date
    end

    it 'returns false if listing is not expired/sold' do
      @listing.status = 'active'
      expect(@listing.repost).to be_falsey
    end
  end

  describe 'soon_expiring_pixis', process: true  do
    before { @listing.save! }
    it "includes active listings" do 
      update_pixi @listing, 'active', 4
    end
	
    it "includes expired listings" do
      update_pixi @listing, 'expired', 4
      expect(Listing.soon_expiring_pixis(4, 'expired').count(:all)).not_to eq 0
    end
	
    it "includes expired listings" do
      update_pixi @listing, 'expired', 4
      expect(Listing.soon_expiring_pixis(4, ['expired', 'active']).count(:all)).not_to eq 0
    end
	
    it "includes active listings" do
      update_pixi @listing, 'active', 5
      expect(Listing.soon_expiring_pixis(5, ['expired', 'active']).count(:all)).not_to eq 0
    end
	
    it "includes default active listings" do
      update_pixi @listing, 'active', 7
      expect(Listing.soon_expiring_pixis.count(:all)).not_to eq 0
    end
  end
  
  describe 'not soon_expiring_pixis', process: true  do  
    it "does not include active listings" do 
      update_pixi @listing, 'active', 10
      expect(Listing.soon_expiring_pixis(8).count(:all)).to eq 0
    end
	
    it "does not include expired listings" do 
      update_pixi @listing, 'expired', 4
      expect(Listing.soon_expiring_pixis(3).count(:all)).to eq 0
    end
	
    it "does not include expiring early listings" do 
      update_pixi @listing, 'expired', 4
      expect(Listing.soon_expiring_pixis(5).count(:all)).to eq 0
    end
	
    it "does not include active listings" do 
      update_pixi @listing, 'active', 4
      expect(Listing.soon_expiring_pixis(5, nil).count(:all)).to eq 0
    end
	
    it "does not include active listings" do 
      update_pixi @listing, ['expired', 'new'], 5
      expect(Listing.soon_expiring_pixis(5, ['expired', 'new']).count(:all)).to eq 0
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
    it { expect(Listing.get_by_city(0, 1)).not_to include @listing } 
    it "should be able to toggle get_active" do
      @site = create :site, site_type_code: 'city', name: 'SF'
      @site.contacts.create(FactoryGirl.attributes_for(:contact, address: '101 California', city: 'SF', state: 'CA', zip: '94111'))
      @listing.update_attribute(:site_id, @site.id)
      @listing.update_attribute(:status, 'removed')
      expect(Listing.get_by_city(@listing.category_id, @listing.site_id, true)).to be_empty
      expect(Listing.get_by_city(@listing.category_id, @listing.site_id, false)).not_to be_empty
    end

    it "finds active pixis by site_type_code" do
      ['city', 'region', 'state', 'country'].each { |site_type_code|
        site = create(:site, name: 'Detroit', site_type_code: site_type_code)
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
      expect(Listing.invoiceless_pixis).to include @listing
      expect(Listing.invoiceless_pixis(5)).not_to include @listing
    end

    it "does not return pixis with wants less than two days old" do
      @pixi_want.created_at = Time.now
      @pixi_want.save!
      expect(Listing.invoiceless_pixis).not_to include @listing
    end

    it "returns invoiced pixis in job category" do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'employment', pixi_type: 'premium') 
      @listing.category_id = Category.find_by_name("Jobs").id
      @listing.job_type_code = 'FT'
      @listing.save!
      create_invoice
      expect(Listing.invoiceless_pixis).to include @listing
    end

    it "returns invoiced pixis with no price" do
      @listing.price = nil
      @listing.save!
      create_invoice
      expect(Listing.invoiceless_pixis).to include @listing
    end

    it "does not return other pixis with invoices" do
      create_invoice
      expect(Listing.invoiceless_pixis).not_to include @listing
    end
  end

  describe "purchased", process: true  do 
    before :each, run: true do
      create_invoice 'paid', 2
    end

    it { expect(Listing.purchased(@user)).not_to include @listing } 
    it "assigns created_date", run: true do
      expect(Listing.purchased(@invoice.buyer).last.created_date.to_s).to eq @invoice.updated_at.to_s
    end
    it "includes buyer listings", run: true do 
      expect(Listing.purchased(@invoice.buyer).count(:all)).to eq 2
    end
    it "only returns necessary attributes", run: true do
      expect(Listing.purchased(@invoice.buyer).last.title).to eq(@listing.title)
      expect(Listing.purchased(@invoice.buyer).last.attributes[:color]).to be_nil
    end
  end

  describe "sold_list", process: true  do 
    before :each, run: true do
      create_invoice 'paid', 2
    end

    it { expect(Listing.sold_list).not_to include @listing } 
    it "assigns created_date", run: true do
      expect(Listing.sold_list.last.created_date.to_s).to eq @invoice.updated_at.to_s
    end
    it "includes sold listings", run: true do 
      @listing.save
      expect(Listing.sold_list.count(:all)).to eq 2
    end
    it "only returns necessary attributes", run: true do
      expect(Listing.sold_list.last.title).to eq(@invoice.listings.first.title)
      expect(Listing.sold_list.last.attributes[:color]).to be_nil
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
      expect(Listing.active.count(:all)).to eq 0
      expect(User.find(@listing.seller_id).active_listings_count).to eq 0
    end
    it "resets cache on update" do
      listing = FactoryGirl.create(:listing, seller_id: @user.id, quantity: 1, status: 'inactive') 
      listing.update_attribute(:status, 'active')
      expect(@user.reload.active_listings_count).to eq 1
    end
  end

  describe 'get_by_url', process: true do
    before :each do
      @listing.save!
    end
    context 'by user' do
      it { expect(Listing.get_by_url(@user.url, 'mbr')).to include @listing }
      it { expect(Listing.get_by_url('abcd', 'mbr')).to be_nil }
    end
    context 'by site' do
      before :each do
        @loc = create :site, site_type_code: 'pub'
      end
      it 'loads site url' do
        listing = create :listing, site_id: @loc.id, seller_id: @user.id, quantity: 1 
        expect(Listing.get_by_url(@loc.url, 'pub')).to include listing
      end
      it { expect(Listing.get_by_url('abcd', 'pub')).to be_blank }
    end
  end

  describe 'latlng', process: true do
    it 'has coordinates', run: true do
      @listing.lat, @listing.lng = [42.4348, -83.125]
      expect(@listing.latlng).not_to be_nil
    end
    it 'gets coordinates from contact', run: true do
      @site = create :site, site_type_code: 'city', name: 'San Francisco'
      @site.contacts.create(FactoryGirl.attributes_for(:contact, address: '101 California',
        city: 'SF', state: 'CA', zip: '94111', lat: 37.799367, lng: 122.398407))
      @listing.update_attribute(:site_id, @site.id)
      expect(@listing.latlng).not_to be_nil
    end
    it { expect(@listing.latlng[0]).to be_nil }
  end

  describe 'any_sold?' do
    before :each, run: true do
      create_invoice 'paid'
    end

    it { expect(@listing.any_sold?).not_to be_truthy } 
    it "has paid invoices", run: true do 
      expect(@listing.any_sold?).to be_truthy  
    end
  end

  describe 'board_fields' do
    before :each do
      @listing.save!
    end

    it "contains correct fields" do
      listing = Listing.active.board_fields
      expect(listing.first.pixi_id).to eq @listing.pixi_id  
    end
    it { expect(Listing.active.board_fields).not_to include @listing.created_at }
  end

  describe 'as_csv' do
    before { @listing.save! }
    it "exports data as CSV file" do
      # call check_category_and_location to load created_date
      listing = Listing.check_category_and_location('active', nil, nil, true).first
      csv_string = listing.as_csv(style: 'active')
      expect(csv_string.keys).to match_array(['Title', 'Category', 'Description', 'Location',
                                 ListingProcessor.new(listing).toggle_user_name_header(listing.status, 'index'),
                                 'Expiration Date']) 
      expect(csv_string.values).to match_array([listing.title, listing.category_name, listing.description, listing.site_name,
                                   ListingProcessor.new(listing).toggle_user_name_row(listing.status, listing, 'index'),
                                   listing.display_date(listing.created_date)])
    end
  end

  describe 'update_buy_now' do
    it 'sets buy_now_flg for business sellers' do
      seller = create :business_user
      seller.bank_accounts.create FactoryGirl.attributes_for :bank_account
      { listing: Listing, temp_listing: TempListing }.each do |record, model|
        listing = create record, seller_id: seller.id
        expect(listing.buy_now_flg).to be_nil
        model.update_buy_now
        listing.reload
        expect(listing.buy_now_flg).to be_truthy
      end
    end

    it 'does not set buy_now_flg for business sellers w/o bank acct' do
      seller = create :business_user
      { listing: Listing, temp_listing: TempListing }.each do |record, model|
        listing = create record, seller_id: seller.id
        expect(listing.buy_now_flg).to be_nil
        model.update_buy_now
        listing.reload
        expect(listing.buy_now_flg).not_to be_truthy
      end
    end

    it 'does not set buy_now_flg for non-business sellers' do
      temp_listing = create(:temp_listing, seller_id: @user.id)
      { @listing => Listing, temp_listing => TempListing }.each do |object, model|
        object.save
        model.update_buy_now
        object.reload
        expect(object.buy_now_flg).to be_nil
      end
    end
  end

  describe 'update_fulfillment_types' do
    it 'sets fulfillment_type_code to A for business sellers' do
      seller = create :business_user
      seller.bank_accounts.create FactoryGirl.attributes_for :bank_account
      { listing: Listing, temp_listing: TempListing }.each do |record, model|
        listing = create record, seller_id: seller.id
        listing.update_attribute(:fulfillment_type_code, nil)
        model.update_fulfillment_types
        listing.reload
        expect(listing.reload.fulfillment_type_code).to eq 'A'
      end
    end

    it 'does not set fulfillment_type_code if bank account is not set up' do
      seller = create :business_user
      { listing: Listing, temp_listing: TempListing }.each do |record, model|
        listing = create record, seller_id: seller.id
        listing.update_attribute(:fulfillment_type_code, nil)
        model.update_fulfillment_types
        listing.reload
        expect(listing.fulfillment_type_code).not_to eq 'A'
      end
    end

    it 'sets fulfillment_type_code to P for non-business sellers' do
      temp_listing = create(:temp_listing, seller_id: @user.id)
      { @listing => Listing, temp_listing => TempListing }.each do |object, model|
        object.update_attribute(:fulfillment_type_code, nil)
        object.save
        model.update_fulfillment_types
        object.reload
        expect(object.fulfillment_type_code).to eq 'P'
      end
    end
  end

  describe 'condition' do
    before do
      @ctype = FactoryGirl.create(:condition_type)
      @listing1 = FactoryGirl.create(:listing, seller_id: @user.id, condition_type_code: @ctype.code)
    end

    it "shows condition description" do
      expect(@listing1.condition).to eq @ctype.description.titleize
    end

    it "does not show condition description" do
      expect(@listing.condition).to be_nil
    end
  end

  describe 'delivery_type' do
    before do
      @ftype = FactoryGirl.create(:fulfillment_type)
      @listing1 = FactoryGirl.create(:listing, seller_id: @user.id, fulfillment_type_code: @ftype.code)
    end

    it "shows delivery_type description" do
      expect(@listing1.delivery_type).to eq @ftype.description.titleize
    end

    it "does not show delivery_type description" do
      @listing.update_attribute(:fulfillment_type_code, nil)
      expect(@listing.delivery_type).to be_nil
    end
  end
end
