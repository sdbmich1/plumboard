require 'spec_helper'

describe TempListing do
  before(:all) do
    @user = create :pixi_user
    @category = FactoryGirl.create(:category, pixi_type: 'basic') 
  end
  before(:each) do
    @temp_listing = FactoryGirl.build(:temp_listing, seller_id: @user.id)
  end

  subject { @temp_listing }

  describe 'attributes', base: true do
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
    it { is_expected.to respond_to(:event_type_code) }
    it { is_expected.to respond_to(:job_type_code) }
    it { is_expected.to respond_to(:repost_flg) }
    it { is_expected.to respond_to(:quantity) }
    it { is_expected.to respond_to(:condition_type_code) }
    it { is_expected.to respond_to(:color) }
    it { is_expected.to respond_to(:other_id) }
    it { is_expected.to respond_to(:mileage) }
    it { is_expected.to respond_to(:item_type) }
    it { is_expected.to respond_to(:item_size) }
    it { is_expected.to respond_to(:user) }
    it { is_expected.to respond_to(:site) }
    it { is_expected.to respond_to(:transaction) }
    it { is_expected.to respond_to(:pictures) }
    it { is_expected.to respond_to(:category) }
    it { is_expected.to respond_to(:job_type) }
    it { is_expected.to respond_to(:event_type) }
    it { is_expected.to respond_to(:set_flds) }
    it { is_expected.to respond_to(:generate_token) }
    it { is_expected.to respond_to(:buy_now_flg) }
    it { is_expected.to respond_to(:est_ship_cost) }
    it { is_expected.to respond_to(:sales_tax) }
    it { is_expected.to respond_to(:fulfillment_type_code) }
    it { is_expected.to belong_to(:fulfillment_type).with_foreign_key('fulfillment_type_code') }
    it { is_expected.to allow_value(50.00).for(:price) }
    it { is_expected.to allow_value(5000).for(:price) }
    it { is_expected.to allow_value('').for(:price) }
    it { is_expected.not_to allow_value(500000).for(:price) }
    it { is_expected.not_to allow_value(5000.001).for(:price) }
    it { is_expected.not_to allow_value(-5000.00).for(:price) }
    it { is_expected.not_to allow_value('$5000.0').for(:price) }
  end

  describe "when site_id is empty" do
    before { @temp_listing.site_id = "" }
    it { is_expected.not_to be_valid }
  end
  
  describe "when site_id is entered" do
    before { @temp_listing.site_id = 1 }
    it { expect(@temp_listing.site_id).to eq(1) }
  end

  describe "when seller_id is empty" do
    before { @temp_listing.seller_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when seller_id is entered" do
    before { @temp_listing.seller_id = 1 }
    it { expect(@temp_listing.seller_id).to eq(1) }
  end

  describe "when transaction_id is entered" do
    before { @temp_listing.transaction_id = 1 }
    it { expect(@temp_listing.transaction_id).to eq(1) }
  end

  describe "when start_date is empty" do
    before { @temp_listing.start_date = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when start_date is entered" do
    before { @temp_listing.start_date = Time.now }
    it { is_expected.to be_valid }
  end

  describe "when title is empty" do
    before { @temp_listing.title = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when title is entered" do 
    before { @temp_listing.title = "chair" }
    it { expect(@temp_listing.title).to eq("chair") }
  end

  describe "when title is too large" do
    before { @temp_listing.title = "a" * 81 }
    it { is_expected.not_to be_valid }
  end

  describe "when description is entered" do 
    before { @temp_listing.description = "chair" }
    it { expect(@temp_listing.description).to eq("chair") }
  end

  describe "when description is empty" do
    before { @temp_listing.description = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when category_id is entered" do 
    before { @temp_listing.category_id = 1 }
    it { expect(@temp_listing.category_id).to eq(1) }
  end

  describe "when category_id is empty" do
    before { @temp_listing.category_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe 'set_end_date', date: true do
    it "sets correct end date" do
      temp_listing = FactoryGirl.build(:temp_listing, seller_id: @user.id)
      expect(temp_listing.set_end_date).to be > Date.today + 1.day
    end

    it "sets incorrect end date" do
      temp_listing = FactoryGirl.build(:temp_listing, seller_id: @user.id, start_date: nil)
      expect(temp_listing.set_end_date).to be_nil
    end

    it 'sets to event_end_date' do
      @cat = FactoryGirl.create(:category, category_type_code: 'event', name: 'Event', pixi_type: 'premium') 
      @temp_listing.category_id = @cat.id
      @temp_listing.event_type_code = 'party'
      @temp_listing.event_start_date = Date.today+1.day 
      @temp_listing.event_end_date = Date.today+3.days 
      expect(@temp_listing.set_end_date).to eq @temp_listing.event_end_date
    end
  end

  describe 'set_flds' do
    it "sets fields" do
      @temp = create(:temp_listing, seller_id: @user.id, status: nil)
      expect(@temp.status).to eq('new')
      expect(@temp.pixi_id).not_to be_nil
    end

    it "does not set fields" do
      temp_listing = FactoryGirl.build(:temp_listing, seller_id: @user.id, status: 'edit', pixi_id: '123456')
      temp_listing.save
      expect(temp_listing.status).not_to eq('new')
      expect(temp_listing.pixi_id).to eq('123456')
    end
  end

  describe "seller listings", base: true do
    before { @temp_listing.save! }
    it { expect(TempListing.get_by_seller(@user, 'new', false)).not_to be_empty }

    it "does not get all listings for non-admin" do
      @temp_listing.seller_id = 100
      @temp_listing.save
      expect(TempListing.get_by_seller(@user, 'new', false)).not_to include @temp_listing
    end

    it "gets all listings for admin" do
      @other = FactoryGirl.create(:pixi_user)
      temp_listing = FactoryGirl.create(:temp_listing, seller_id: @other.id) 
      @user.user_type_code = "AD"
      @user.uid = 0
      @user.save
      expect(TempListing.get_by_seller(@user, 'new').count).to eq 2
    end
  end

  describe "get_by_status should not include inactive listings" do
    it { expect(TempListing.get_by_status('inactive')).not_to include (@temp_listing) }
  end

  describe "should return correct site name" do 
    it { expect(@temp_listing.site_name).not_to be_empty } 
  end

  describe "should not find correct site name" do 
    temp_listing = FactoryGirl.create :temp_listing, site_id: 100
    it { expect(temp_listing.site_name).to be_nil } 
  end

  describe "should find correct category name" do 
    it { expect(@temp_listing.category_name).to eq(@category.name.titleize) } 
  end

  describe "should not find correct category name" do 
    temp_listing = FactoryGirl.build :temp_listing, category_id: nil
    it { expect(temp_listing.category_name).to be_nil } 
  end

  describe "seller name" do 
    let(:user) { FactoryGirl.create(:pixi_user) }
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id) }
    it { expect(temp_listing.seller_name).to eq(user.name) } 

    it "does not find seller name" do 
      temp_listing.seller_id = 100 
      expect(temp_listing.seller_name).not_to eq(user.name)
    end
  end

  describe "seller email" do 
    let(:user) { FactoryGirl.create(:pixi_user) }
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id) }
    it { expect(temp_listing.seller_email).to eq(user.email) } 

    it "does not find seller email" do 
      temp_listing.seller_id = 100 
      expect(temp_listing.seller_email).not_to eq(user.email)
    end
  end

  describe "should find correct seller photo" do 
    let(:user) { FactoryGirl.create(:pixi_user) }
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id) }
    it { expect(temp_listing.seller_photo).not_to be_nil } 
  end

  describe "should not find correct seller photo" do 
    temp_listing = FactoryGirl.create :temp_listing, seller_id: 100
    it { expect(temp_listing.seller_photo).to be_nil } 
  end

  describe "should have a transaction" do 
    it { expect(@temp_listing.has_transaction?).to be_truthy }
  end

  describe "should not have a transaction" do 
    temp_listing = FactoryGirl.create :temp_listing, transaction_id: nil
    it { expect(temp_listing.has_transaction?).not_to be_truthy }
  end

  describe "should verify if seller name is an alias" do  
    temp_listing = FactoryGirl.create :temp_listing, show_alias_flg: 'yes'
    it { expect(temp_listing.alias?).to be_truthy }
  end

  describe "should not have an alias" do 
    temp_listing = FactoryGirl.create :temp_listing, show_alias_flg: 'no'
    it { expect(temp_listing.alias?).not_to be_truthy }
  end

  describe "seller?" do 
    let(:user) { FactoryGirl.create :pixi_user }
    let(:user2) { FactoryGirl.create :pixi_user, first_name: 'Kate', last_name: 'Davis', email: 'katedavis@pixitest.com' }
    let(:temp_listing) { FactoryGirl.create :temp_listing, seller_id: user.id }

    it "should verify user is seller" do 
      expect(temp_listing.seller?(user)).to be_truthy 
    end

    it "should not verify user is seller" do 
      expect(temp_listing.seller?(user2)).not_to be_truthy 
    end
  end

  describe "should return a short description" do 
    temp_listing = FactoryGirl.create :temp_listing, description: "a" * 500
    it { expect(temp_listing.brief_descr.length).to eq(100) }
    it { expect(temp_listing.summary).to be_truthy }
  end

  describe "should not return a short description" do 
    temp_listing = FactoryGirl.create :temp_listing, description: 'qqq'
    it { expect(temp_listing.brief_descr.length).not_to eq(100) }
  end

  describe "should not return a summary" do 
    temp_listing = FactoryGirl.build :temp_listing, description: nil
    it { expect(temp_listing.summary).not_to be_truthy }
  end

  describe "should return a nice title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: 'guitar - acoustic (for sale)'
    it { expect(temp_listing.nice_title).to eq('Guitar - Acoustic (For Sale) - ') }
  end

  describe "should not return a nice title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: 'qqq'
    it { expect(temp_listing.nice_title).not_to eq('Guitar For Sale') }
  end

  describe "should return a short title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: "a" * 40
    it { expect(temp_listing.short_title.length).not_to eq(40) }
  end

  describe "should not return a short title" do 
    temp_listing = FactoryGirl.build :temp_listing, title: 'qqq'
    it { expect(temp_listing.short_title.length).not_to eq(18) }
  end

  describe "set flds" do 
    let(:temp_listing) { FactoryGirl.create :temp_listing, status: "" }

    it "should call set flds" do 
      expect(temp_listing.status).to eq("new")
    end
  end

  describe "invalid set flds" do 
    let(:temp_listing) { FactoryGirl.build :temp_listing, title: nil, status: "" }
    
    it "should not call set flds" do 
      temp_listing.save
      expect(temp_listing.status).not_to eq('new')
    end
  end 

  describe "should return site count > 0" do 
    temp_listing = FactoryGirl.create :temp_listing, site_id: 100
    it { expect(temp_listing.get_site_count).to eq(0) } 
  end

  describe "should not return site count > 0" do 
    it { expect(@temp_listing.get_site_count).not_to eq(0) } 
  end

  describe "transactions", base: true  do
    let(:transaction) { FactoryGirl.create :transaction }
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') 
      stub_const("PIXI_PREMIUM_PRICE", 10.00)
      @temp_listing.save!
    end

    context "get_by_status should include new listings" do
      it { expect(TempListing.get_by_status('active')).not_to be_empty } 
    end

    it "should not submit order" do 
      @temp_listing.category_id = @cat.id
      @temp_listing.save
      expect(@temp_listing.submit_order(nil)).not_to be_truthy
    end

    it "should submit order" do 
      expect(@temp_listing.submit_order(transaction.id)).to be_truthy
    end

    it "should resubmit order" do 
      temp_listing = FactoryGirl.create :temp_listing, transaction_id: transaction.id
      expect(temp_listing.resubmit_order).to be_truthy 
    end

    it "should not resubmit order" do 
      temp_listing = FactoryGirl.create :temp_listing, transaction_id: nil, category_id: @cat.id
      expect(temp_listing.resubmit_order).not_to be_truthy
    end
  end

  describe "approved order", base: true  do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "approve order should not return approved status" do 
      @temp_listing.approve_order(nil)
      expect(@temp_listing.status).not_to eq('approved')
    end

    it "approve order should return approved status" do 
      temp_listing.approve_order(user)
      expect(temp_listing.status).to eq('approved')
    end
  end

  describe "deny order", base: true  do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "deny order should not return denied status" do 
      @temp_listing.deny_order(nil)
      expect(@temp_listing.status).not_to eq('denied')
    end

    it "deny order should return denied status" do 
      temp_listing.deny_order(user, 'Improper Content')
      expect(temp_listing.status).to eq('denied')
      expect(temp_listing.explanation).to eq('Improper Content')
    end
  end

  describe "draft listings", base: true  do
    before { @temp_listing.save! }
    it { expect(TempListing.draft.count).to eq(1) }

    it "should not include pending temp_listings" do
      @temp_listing.status = 'pending' 
      @temp_listing.save
      expect(TempListing.draft).not_to include @temp_listing 
    end

    it "only returns necessary attributes" do
      expect(TempListing.draft.first.title).to eq @temp_listing.title
      expect(TempListing.draft.first.attributes[:color]).to be_nil
    end
  end

  describe "pixter", base: true  do 
    before do
      @pixter = create :pixi_user, user_type_code: 'PT'
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
      @temp_listing = FactoryGirl.create(:temp_listing, seller_id: @user.id, pixan_id: @pixter.id) 
    end

    it "should verify user is pixter" do 
      expect(@temp_listing.pixter?(@pixter)).to be_truthy 
    end

    it "should not verify user is pixter" do 
      expect(@temp_listing.pixter?(@user2)).not_to be_truthy 
    end
  end

  describe "editable", base: true do 
    before do
      @pixter = create :pixi_user, user_type_code: 'PT'
      @admin = create :admin, confirmed_at: Time.now
      @support = create :support, confirmed_at: Time.now
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
      @temp_listing = FactoryGirl.create(:temp_listing, seller_id: @user.id, pixan_id: @pixter.id) 
    end

    it "is editable" do 
      expect(@temp_listing.editable?(@pixter)).to be_truthy 
      expect(@temp_listing.editable?(@user)).to be_truthy 
      expect(@temp_listing.editable?(@admin)).to be_truthy 
      expect(@temp_listing.editable?(@support)).to be_truthy 
    end

    it "is not editable" do 
      expect(@temp_listing.editable?(@user2)).not_to be_truthy 
    end
  end

  describe "dup pixi", process: true  do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "does not return new listing" do 
      listing = FactoryGirl.build :temp_listing, seller_id: user.id 
      new_listing = listing.dup_pixi(true) rescue nil
      expect(new_listing).to be_nil
    end

    it 'returns new listing' do
      @new_listing = @temp_listing.dup_pixi(true)
      expect(@new_listing.pixi_id).to eq(@temp_listing.pixi_id)
      expect(Listing.where(pixi_id: @new_listing.pixi_id).count).to eq(1)
      # expect(TempListing.where(pixi_id: @new_listing.pixi_id).count).to eq(0)
    end

    it "returns edit listing w/ associations" do 
      @listing = FactoryGirl.create(:listing, seller_id: user.id)
      @pixi_want = user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
      @pixi_like = user.pixi_likes.create FactoryGirl.attributes_for :pixi_like, pixi_id: @listing.pixi_id
      @temp_listing = @listing.dup_pixi(false)
      expect(@listing.pixi_id).to eq(@temp_listing.pixi_id)
      expect(@temp_listing.status).to eq('edit')
      @temp_listing.title, @temp_listing.price = 'Super Fender Bass', 999.99
      picture = @temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo0.jpg")
      @temp_listing.save!; sleep 2
      expect(@temp_listing.pictures.count).to be > 1
      expect(@temp_listing.reload.title).to eq 'Super Fender Bass'
      expect(@listing.title).not_to eq 'Super Fender Bass'
      @dup_listing = @temp_listing.reload.dup_pixi(true)
      #expect(@dup_listing.title).not_to eq(@listing.title)
      expect(@dup_listing.status).to eq('active')
      expect(@dup_listing.price).to eq(999.99)
      expect(@dup_listing.wanted_count).to eq(1)
      expect(@dup_listing.liked_count).to eq(1)
      expect(@dup_listing.pictures.count).to be > 1
      expect(TempListing.where(pixi_id: @listing.pixi_id).count).to eq(1)
      expect(TempListing.where("title like 'Super%'").count).to eq(1)
      expect(Listing.where(pixi_id: @listing.pixi_id).count).to eq(1)
      expect(Listing.where("title like 'Super%'").count).to eq(1)
    end

    it "returns edit listing w/ associations - remove photo" do 
      @listing = FactoryGirl.create(:listing_with_pictures, seller_id: user.id)
      @pixi_want = user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
      @pixi_like = user.pixi_likes.create FactoryGirl.attributes_for :pixi_like, pixi_id: @listing.pixi_id
      expect(@listing.pictures.count).to eq(2)
      @temp_listing = @listing.dup_pixi(false)
      expect(@listing.pixi_id).to eq(@temp_listing.pixi_id)
      expect(@temp_listing.status).to eq('edit')
      expect(@temp_listing.pictures.count).to eq(2)
      @temp_listing.title, @temp_listing.price = 'Super Fender Bass', 999.99
      @temp_listing.save!
      @temp_listing.delete_photo(@temp_listing.pictures.first.id)
      expect(@temp_listing.pictures.count).to eq(1)
      @dup_listing = @temp_listing.dup_pixi(true)
      expect(@dup_listing.title).not_to eq(@listing.title)
      expect(@dup_listing.status).to eq('active')
      expect(@dup_listing.price).to eq(999.99)
      expect(@dup_listing.wanted_count).to eq(1)
      expect(@dup_listing.liked_count).to eq(1)
      expect(Listing.where(pixi_id: @listing.pixi_id).count).to eq(1)
      expect(Listing.where("title like 'Super%'").count).to eq(1)
    end

    it "returns edit listing w/ associations - remove only photo" do 
      @listing = FactoryGirl.create(:listing_with_pictures, seller_id: user.id)
      @pixi_want = user.pixi_wants.create FactoryGirl.attributes_for :pixi_want, pixi_id: @listing.pixi_id
      @pixi_like = user.pixi_likes.create FactoryGirl.attributes_for :pixi_like, pixi_id: @listing.pixi_id
      @temp_listing = @listing.dup_pixi(false)
      expect(@listing.pixi_id).to eq(@temp_listing.pixi_id)
      expect(@temp_listing.status).to eq('edit')
      @temp_listing.title, @temp_listing.price = 'Super Fender Bass', 999.99
      @temp_listing.delete_photo(@temp_listing.pictures.first.id)
      expect(@temp_listing.pictures.count).to eq(1)
      @dup_listing = @temp_listing.dup_pixi(true)
      expect(@dup_listing.title).not_to eq(@listing.title)
      expect(@dup_listing.status).to eq('active')
      expect(@dup_listing.price).to eq(999.99)
      expect(@dup_listing.wanted_count).to eq(1)
      expect(@dup_listing.liked_count).to eq(1)
      expect(Listing.where(pixi_id: @listing.pixi_id).count).to eq(1)
      expect(Listing.where("title like 'Super%'").count).to eq(1)
    end
  end

  describe "should verify new status" do 
    temp_listing = FactoryGirl.build :temp_listing, status: 'new'
    it { expect(temp_listing.new_status?).to be_truthy }
  end

  describe "should not verify new status" do 
    temp_listing = FactoryGirl.build :temp_listing, status: 'pending'
    it { expect(temp_listing.new_status?).not_to be_truthy }
  end

  describe "must have pictures", base: true  do
    let(:temp_listing) { FactoryGirl.build :invalid_temp_listing }

    it "should not save w/o at least one picture" do
      picture = temp_listing.pictures.build
      expect(temp_listing).not_to be_valid
    end

    it "should save with at least one picture" do
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save
      expect(temp_listing).to be_valid
    end
  end

  describe "delete photo", base: true  do
    let(:temp_listing) { FactoryGirl.create :temp_listing }

    it "should not delete photo" do 
      pic = temp_listing.pictures.first
      expect(temp_listing.delete_photo(pic.id)).not_to be_truthy
      expect(temp_listing.delete_photo(5000)).not_to be_truthy
    end

    it "deletes photo w/ one photo" do 
      pic = temp_listing.pictures.first
      expect(temp_listing.delete_photo(pic.id, 0)).to be_truthy
      expect(temp_listing.pictures(true).size).to eq 0
      expect(temp_listing).not_to be_valid
    end

    it "should delete photo" do 
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save
      pic = temp_listing.pictures.first
      expect(temp_listing.delete_photo(pic.id)).to be_truthy
    end
  end

  describe 'premium?' do
    before { @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') }
    it 'should return true' do
      temp_listing = FactoryGirl.create(:temp_listing, category_id: @cat.id) 
      expect(temp_listing.premium?).to be_truthy
    end

    it 'should not return true' do
      expect(@temp_listing.premium?).not_to be_truthy
    end
  end

  describe 'pictures', base: true  do
    before(:each) do
      @temp_listing.save!
      @sr = @temp_listing.pictures.create FactoryGirl.attributes_for(:picture)
    end
				            
    it "should have pictures" do 
      expect(@temp_listing.pictures).to include(@sr)
    end

    it "should not have too many pictures" do 
      20.times { @temp_listing.pictures.build FactoryGirl.attributes_for(:picture) }
      @temp_listing.save
      expect(@temp_listing).not_to be_valid
    end

    it "should destroy associated pictures" do
      @temp_listing.destroy
      [@sr].each do |s|
         expect(Picture.find_by_id(s.id)).to be_nil
       end
    end  
  end  

  describe '.same_day?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Events', pixi_type: 'premium') 
      @temp_listing.category_id = @cat.id
    end

    it "should respond to same_day? method" do
      expect(@temp_listing).to respond_to(:same_day?)
    end

    it "should be the same day" do
      @temp_listing.event_start_date = Date.today
      @temp_listing.event_end_date = Date.today
      expect(@temp_listing.same_day?).to be_truthy
    end

    it "should not be the same day" do
      @temp_listing.event_start_date = Date.today
      @temp_listing.event_end_date = Date.today+1.day
      expect(@temp_listing.same_day?).to be_falsey 
    end
  end

  describe 'sold?' do
    it 'should return true' do
      @temp_listing.status = 'sold'
      expect(@temp_listing.sold?).to be_truthy
    end

    it 'should not return true' do
      expect(@temp_listing.sold?).not_to be_truthy
    end
  end

  describe '.pending?' do
    it "is not pending" do
      expect(@temp_listing.pending?).to be_falsey 
    end

    it "is pending" do
      @temp_listing.status = 'pending'
      expect(@temp_listing.pending?).to be_truthy 
    end
  end

  describe '.denied?' do
    it "is not denied" do
      expect(@temp_listing.denied?).to be_falsey 
    end

    it "is denied" do
      @temp_listing.status = 'denied'
      expect(@temp_listing.denied?).to be_truthy 
    end
  end

  describe '.edit?' do
    it "is not edit" do
      expect(@temp_listing.edit?).to be_falsey 
    end

    it "is edit" do
      @temp_listing.status = 'edit'
      expect(@temp_listing.edit?).to be_truthy 
    end
  end

  describe '.event?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'event', pixi_type: 'premium') 
    end

    it "is not an event" do
      expect(@temp_listing.event?).to be_falsey 
    end

    it "is an event" do
      @temp_listing.category_id = @cat.id
      expect(@temp_listing.event?).to be_truthy 
    end
  end

  describe '.has_year?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'asset', pixi_type: 'premium') 
    end

    it "does not have a year" do
      expect(@temp_listing.has_year?).to be_falsey 
    end

    it "has a year" do
      @temp_listing.category_id = @cat.id
      expect(@temp_listing.has_year?).to be_truthy 
    end
  end

  describe '.job?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'employment', pixi_type: 'premium') 
    end

    it "is not a job" do
      expect(@temp_listing.job?).to be_falsey 
    end

    it "is a job" do
      @temp_listing.category_id = @cat.id
      expect(@temp_listing.job?).to be_truthy 
    end

    it "is not valid" do
      @temp_listing.category_id = @cat.id
      expect(@temp_listing).not_to be_valid
    end

    it "is valid" do
      create :job_type
      @temp_listing.category_id = @cat.id
      @temp_listing.job_type_code = 'CT'
      expect(@temp_listing).to be_valid
    end
  end

  describe '.free?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') 
    end

    it "is not free" do
      stub_const("PIXI_PREMIUM_PRICE", 10.00)
      expect(PIXI_PREMIUM_PRICE).to eq(10.00)
      @temp_listing.category_id = @cat.id
      @temp_listing.save
      expect(@temp_listing.free?).to be_falsey 
    end

    it "is free" do
      expect(@temp_listing.free?).to be_truthy 
    end
  end

  describe "is not pixi_post" do 
    it { expect(@temp_listing.pixi_post?).not_to be_truthy }
  end

  describe "is a pixi_post" do 
    before do 
      @pixan = FactoryGirl.create(:contact_user) 
      @temp_listing.pixan_id = @pixan.id 
      @temp_listing.save
    end
    it { expect(@temp_listing.pixi_post?).to be_truthy }
  end

  describe 'contacts' do
    before(:each) do
      @sr = @temp_listing.contacts.create FactoryGirl.attributes_for(:contact)
    end
				            
    it "should have many contacts" do 
      expect(@temp_listing.contacts).to include(@sr)
    end

    it "should destroy associated contacts" do
      @temp_listing.destroy
      [@sr].each do |s|
         expect(Contact.find_by_id(s.id)).to be_nil
       end
    end  
  end  

  describe 'primary_address' do
    it 'has primary address' do
      @site = create :site
      @contact = @site.contacts.create FactoryGirl.attributes_for(:contact)
      temp_listing = create :temp_listing, seller_id: @user.id, site_id: @site.id
      expect(temp_listing.primary_address).to eq @contact.full_address
    end

    it 'has no primary address' do
      expect(@temp_listing.primary_address).to eq @temp_listing.site_name
    end
  end

  describe "find_pixi" do
    before { @temp_listing.save! }
    it 'finds a pixi' do
      expect(TempListing.find_pixi(@temp_listing.pixi_id)).not_to be_nil
    end

    it 'does not find pixi' do
      expect(TempListing.find_pixi('0')).to be_nil
    end
  end

  describe 'job_type_name' do
    it "shows description" do
      create :job_type
      @temp_listing.job_type_code = 'CT'
      expect(@temp_listing.job_type_name).to eq 'Contract'
    end

    it "does not show description" do
      expect(@temp_listing.job_type_name).to be_nil
    end
  end

  describe 'async_send_notifications', process: true  do
    let(:temp_listing) {create :temp_listing_with_transaction, seller_id: @user.id}
    let(:denied_listing) {create :temp_listing_with_transaction, seller_id: @user.id, status: 'denied'}

    def send_mailer model, msg
      @mailer = double(UserMailer)
      allow(UserMailer).to receive(:delay).and_return(@mailer)
      allow(@mailer).to receive(msg.to_sym).with(model).and_return(@mailer)
    end

    it 'delivers the submitted pixi message' do
      temp_listing.status = 'pending'
      temp_listing.save!
      send_mailer temp_listing, 'send_submit_notice'
    end

    it 'delivers the submitted pixi message for denied pixi' do
      denied_listing.status = 'pending'
      denied_listing.save!
      send_mailer denied_listing, 'send_submit_notice'
      denied_listing.status = 'approved'
      denied_listing.transaction.amt = 0.0
      expect {
	denied_listing.save!
      }.not_to change {Listing.count}.by(1)
    end

    it 'adds listing and transaction' do
      temp_listing.status = 'approved'
      temp_listing.transaction.amt = 0.0
      expect {
	temp_listing.save!
      }.to change {Listing.count}.by(1)
      allow(Listing).to receive(:create).with(temp_listing.attributes).and_return(true)
      expect(temp_listing.transaction.status).to eq('approved')
      expect(temp_listing.transaction.status).not_to eq('pending')
    end

    it 'delivers the denied pixi message' do
      create :admin, email: PIXI_EMAIL
      temp_listing.status = 'denied'
      temp_listing.save!
      send_mailer temp_listing, 'send_denial'
      allow(SystemMessenger).to receive(:send_system_message).with(@user, temp_listing, 'deny').and_return(true)
    end
  end

  describe '.start_date?' do
    it "has no start date" do
      expect(@temp_listing.start_date?).to be_falsey
    end

    it "has a start date" do
      @temp_listing.event_start_date = Time.now
      expect(@temp_listing.start_date?).to be_truthy
    end
  end

  describe 'format_date', date: true  do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :temp_listing, seller_id: user.id }

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

  describe 'display_date', date: true  do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :temp_listing, seller_id: user.id }

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

  describe "date validations", date: true  do
    before do
      @cat = FactoryGirl.create(:category, category_type_code: 'event', name: 'Event', pixi_type: 'premium') 
      @temp_listing.category_id = @cat.id
      @temp_listing.event_type_code = 'party'
      @temp_listing.event_end_date = Date.today+3.days 
      @temp_listing.event_start_time = Time.now+2.hours
      @temp_listing.event_end_time = Time.now+3.hours
    end

    describe 'start date' do
      it "has valid start date" do
        @temp_listing.event_start_date = Date.today+2.days
        expect(@temp_listing).to be_valid
      end

      it "should reject a bad start date" do
        @temp_listing.event_start_date = Date.today-7.days
        expect(@temp_listing).not_to be_valid
      end

      it "should not be valid without a start date" do
        @temp_listing.event_start_date = nil
        expect(@temp_listing).not_to be_valid
      end
    end

    describe 'end date' do
      before do
        @temp_listing.event_start_date = Date.today+2.days 
        @temp_listing.event_start_time = Time.now+2.hours
        @temp_listing.event_end_time = Time.now+3.hours
      end

      it "has valid end date" do
        @temp_listing.event_end_date = Date.today+3.days
        expect(@temp_listing).to be_valid
      end

      it "should reject a bad end date" do
        @temp_listing.event_end_date = ''
        expect(@temp_listing).not_to be_valid
      end

      it "should reject end date < start date" do
        @temp_listing.event_end_date = Date.today-2.days
        expect(@temp_listing).not_to be_valid
      end

      it "should not be valid without a end date" do
        @temp_listing.event_end_date = nil
        expect(@temp_listing).not_to be_valid
      end
    end

    describe 'start time' do
      before do
        @temp_listing.event_start_date = Date.today+2.days 
        @temp_listing.event_end_date = Date.today+3.days 
        @temp_listing.event_end_time = Time.now+3.hours
      end

      it "has valid start time" do
        @temp_listing.event_start_time = Time.now+2.hours
        expect(@temp_listing).to be_valid
      end

      it "should reject a bad start time" do
        @temp_listing.event_start_time = ''
        expect(@temp_listing).not_to be_valid
      end

      it "should not be valid without a start time" do
        @temp_listing.event_start_time = nil
        expect(@temp_listing).not_to be_valid
      end
    end

    describe 'end time' do
      before do
        @temp_listing.event_start_date = Date.today+2.days 
        @temp_listing.event_end_date = Date.today+3.days 
        @temp_listing.event_start_time = Time.now+2.hours
      end

      it "has valid end time" do
        @temp_listing.event_end_time = Time.now+3.hours
        expect(@temp_listing).to be_valid
      end

      it "should reject a bad end time" do
        @temp_listing.event_end_time = ''
        expect(@temp_listing).not_to be_valid
      end

      it "should reject end time < start time" do
        @temp_listing.event_end_date = @temp_listing.event_start_date
        @temp_listing.event_end_time = Time.now.advance(:hours => -2)
        expect(@temp_listing).not_to be_valid
      end

      it "should not be valid without a end time" do
        @temp_listing.event_end_time = nil
        expect(@temp_listing).not_to be_valid
      end
    end
  end

  describe "get_by_city", process: true do
    it "should get listings" do
      temp_listing = FactoryGirl.create :temp_listing
      temp_listing.status = 'pending'
      temp_listing.save!
      expect(TempListing.get_by_city(0, 1, false)).not_to include temp_listing
      expect(TempListing.get_by_city(temp_listing.category_id, temp_listing.site_id, false)).not_to be_empty
    end

    it "finds by site_type_code" do
      ['city', 'region', 'state', 'country'].each { |site_type_code_name|
        site = create(:site, name: 'Detroit', site_type_code: site_type_code_name)
        lat, lng = Geocoder.coordinates('Detroit, MI')
        site.contacts.create(FactoryGirl.attributes_for(:contact, address: 'Metro', city: 'Detroit', state: 'MI',
          country: 'United States of America', lat: lat, lng: lng))
        temp_listing = create(:temp_listing, seller_id: @user.id, site_id: site.id, category_id: @category.id) 
        expect(TempListing.get_by_city(temp_listing.category_id, temp_listing.site_id, false).first).to eq(temp_listing)
        temp_listing.destroy
      }
    end
  end

  describe "check_category_and_location", process: true do
    before do
      @listings = FactoryGirl.create(:temp_listing)
      @listings.status = 'pending'
      @listings.save
    end

    it "should get all listings of given status if category and location are not specified" do
      expect(TempListing.check_category_and_location('pending', nil, nil)).not_to be_empty
    end

    it "should get listing when category and location are specified" do      
      expect(TempListing.check_category_and_location('pending', @listings.category_id, @listings.site_id)).not_to be_empty
    end

    it "should not return anything if no listings meet the parameters" do
      expect(TempListing.check_category_and_location('removed', 100, 900)).to be_empty
    end
  end

  describe '.event_type', base: true do
    before do
      @etype = FactoryGirl.create(:event_type, code: 'party', description: 'Parties, Galas, and Gatherings')
      @cat = FactoryGirl.create(:category, name: 'Events', category_type_code: 'event')
      @listing1 = FactoryGirl.create(:temp_listing, seller_id: @user.id)
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
      expect(@temp_listing.event_type_code).not_to eq 'party'
    end

    it "shows event_type description" do
      expect(@listing1.event_type_descr).to eq @etype.description.titleize
    end

    it "does not show event_type description" do
      expect(@temp_listing.event_type_descr).to be_nil
    end
  end

  describe 'soon_expiring_pixis', process: true do
    before :each do
      @temp_listing.save
    end

    it "includes active temp listings" do 
      update_pixi @temp_listing, 'edit', 4
      expect(TempListing.soon_expiring_pixis(4, 'edit').count(:all)).not_to eq 0
    end
	
    it "includes expired listings" do
      update_pixi @temp_listing, 'new', 4
      expect(TempListing.soon_expiring_pixis(4, 'new').count(:all)).not_to eq 0
    end
	
    it "includes expired listings" do
      update_pixi @temp_listing, 'new', 4
      expect(TempListing.soon_expiring_pixis(4, ['edit', 'new']).count(:all)).not_to eq 0
    end
  end
  
  describe 'not soon_expiring_pixis', process: true do  
    it "does not include active listings" do 
      update_pixi @temp_listing, 'new', 10
      expect(TempListing.soon_expiring_pixis(8).count(:all)).to eq 0
    end
	
    it "does not include expired listings" do 
      update_pixi @temp_listing, 'edit', 4
      expect(TempListing.soon_expiring_pixis(3, 'new').count(:all)).to eq 0
    end
	
    it "does not include expiring early listings" do 
      update_pixi @temp_listing, 'new', 4
      expect(TempListing.soon_expiring_pixis(5).count(:all)).to eq 0
    end
	
    it "does not include active listings" do 
      update_pixi @temp_listing, 'edit', 4
      expect(TempListing.soon_expiring_pixis(5, nil).count(:all)).to eq 0
    end
	
    it "does not include active listings" do 
      update_pixi @temp_listing, 'new', 4
      expect(TempListing.soon_expiring_pixis(5, ['edit', 'new']).count(:all)).to eq 0
    end
	
    it "does not include active listings" do 
      update_pixi @temp_listing, 'new', 7
      expect(TempListing.soon_expiring_pixis.count(:all)).to eq 0
    end
  end

  describe 'add_listing' do
    it 'has seller id' do
      set_temp_attr @user.id
      @listing = TempListing.add_listing(@attr, @user)
      @listing.save!
      expect(@listing.seller_id).to eq @user.id
    end
    it 'has no user id' do
      set_temp_attr ''
      expect(TempListing.add_listing(@attr, User.new).seller_id).not_to eq @user.id
    end
  end

  describe 'as_csv' do
    before do
      @temp_listing.status = 'pending'
      @temp_listing.save!
    end
    it "exports data as CSV file" do
      # call check_category_and_location to load created_date
      temp_listing = TempListing.check_category_and_location('pending', nil, nil, true).first
      csv_string = temp_listing.as_csv(style: 'pending')
      expect(csv_string.keys).to match_array(['Title', 'Category', 'Description', 'Location',
                                 ListingProcessor.new(temp_listing).toggle_user_name_header(temp_listing.status, 'index'),
                                 temp_listing.status.titleize + ' Date']) 
      expect(csv_string.values).to match_array([temp_listing.title, temp_listing.category_name, temp_listing.description, temp_listing.site_name,
                                   ListingProcessor.new(temp_listing).toggle_user_name_row(temp_listing.status, temp_listing, 'index'),
                                   temp_listing.display_date(temp_listing.created_date)])
    end
  end
end
