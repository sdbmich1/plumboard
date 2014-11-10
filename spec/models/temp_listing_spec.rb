require 'spec_helper'

describe TempListing do
  before(:each) do
    @user = create :pixi_user
    @category = FactoryGirl.create(:category, pixi_type: 'basic') 
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
  it { should respond_to(:event_type_code) }
  it { should respond_to(:job_type_code) }

  it { should respond_to(:user) }
  it { should respond_to(:site) }
  it { should respond_to(:transaction) }
  it { should respond_to(:pictures) }
  it { should respond_to(:category) }
  it { should respond_to(:job_type) }
  it { should respond_to(:event_type) }
  it { should respond_to(:set_flds) }
  it { should respond_to(:generate_token) }
  it { should respond_to(:site_listings) }

  it { should allow_value(50.00).for(:price) }
  it { should allow_value(5000).for(:price) }
  it { should_not allow_value('').for(:price) }
  it { should_not allow_value(500000).for(:price) }
  it { should_not allow_value(5000.001).for(:price) }
  it { should_not allow_value(-5000.00).for(:price) }
  it { should_not allow_value('$5000.0').for(:price) }
  
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

  describe 'set_end_date' do
    it "sets correct end date" do
      temp_listing = FactoryGirl.build(:temp_listing, seller_id: @user.id)
      expect(temp_listing.set_end_date).to be > Date.today + 1.day
    end

    it "sets incorrect end date" do
      temp_listing = FactoryGirl.build(:temp_listing, seller_id: @user.id, start_date: nil)
      expect(temp_listing.set_end_date).to eq Date.today + 1.day
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
      expect(temp_listing.pixi_id).not_to eq('123456')
    end
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

  describe "should include all seller listings for admin" do
    it { TempListing.get_by_seller(0, true).should include @temp_listing }
  end

  describe "should not include incorrect seller listings" do 
    it { TempListing.get_by_seller(0).should_not include @temp_listing } 
  end

  describe "get_by_status should not include inactive listings" do
    it { TempListing.get_by_status('inactive').should_not include (@temp_listing) }
  end

  describe "should return correct site name" do 
    it { @temp_listing.site_name.should_not be_empty } 
  end

  describe "should not find correct site name" do 
    temp_listing = FactoryGirl.create :temp_listing, site_id: 100
    it { temp_listing.site_name.should be_nil } 
  end

  describe "should find correct category name" do 
    it { @temp_listing.category_name.should == @category.name.titleize } 
  end

  describe "should not find correct category name" do 
    temp_listing = FactoryGirl.build :temp_listing, category_id: nil
    it { temp_listing.category_name.should be_nil } 
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
    it { temp_listing.seller_photo.should_not be_nil } 
  end

  describe "should not find correct seller photo" do 
    temp_listing = FactoryGirl.create :temp_listing, seller_id: 100
    it { temp_listing.seller_photo.should be_nil } 
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

  describe "seller?" do 
    let(:user) { FactoryGirl.create :pixi_user }
    let(:user2) { FactoryGirl.create :pixi_user, first_name: 'Kate', last_name: 'Davis', email: 'katedavis@pixitest.com' }
    let(:temp_listing) { FactoryGirl.create :temp_listing, seller_id: user.id }

    it "should verify user is seller" do 
      temp_listing.seller?(user).should be_true 
    end

    it "should not verify user is seller" do 
      temp_listing.seller?(user2).should_not be_true 
    end
  end

  describe "should return a short description" do 
    temp_listing = FactoryGirl.create :temp_listing, description: "a" * 500
    it { temp_listing.brief_descr.length.should == 100 }
  end

  describe "should not return a short description" do 
    temp_listing = FactoryGirl.create :temp_listing, description: 'qqq'
    it { temp_listing.brief_descr.length.should_not == 100 }
  end

  describe "should return a summary" do 
    temp_listing = FactoryGirl.create :temp_listing, description: "a" * 500
    it { temp_listing.summary.should be_true }
  end

  describe "should not return a summary" do 
    temp_listing = FactoryGirl.build :temp_listing, description: nil
    it { temp_listing.summary.should_not be_true }
  end

  describe "should return a nice title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: 'guitar - acoustic (for sale)'
    it { temp_listing.nice_title.should == 'Guitar - Acoustic (For Sale) - ' }
  end

  describe "should not return a nice title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: 'qqq'
    it { temp_listing.nice_title.should_not == 'Guitar For Sale' }
  end

  describe "should return a short title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: "a" * 40
    it { temp_listing.short_title.length.should_not == 40 }
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
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') 
    end

    context "get_by_status should include new listings" do
      it { TempListing.get_by_status('active').should_not be_empty } 
    end

    it "should not submit order" do 
      @temp_listing.category_id = @cat.id
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
      temp_listing = FactoryGirl.create :temp_listing, transaction_id: nil, category_id: @cat.id
      temp_listing.resubmit_order.should_not be_true
    end
  end

  describe "approved order" do
    let(:user) { FactoryGirl.create :pixi_user }
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
    let(:user) { FactoryGirl.create :pixi_user }
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

  describe "draft listings" do
    it { expect(TempListing.draft.count).to eq(1) }

    it "should not include pending temp_listings" do
      @temp_listing.status = 'pending' 
      @temp_listing.save
      TempListing.draft.should_not include @temp_listing 
    end
  end

  describe "pixter" do 
    before do
      @pixter = create :pixi_user, user_type_code: 'PT'
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
      @temp_listing = FactoryGirl.create(:temp_listing, seller_id: @user.id, pixan_id: @pixter.id) 
    end

    it "should verify user is pixter" do 
      @temp_listing.pixter?(@pixter).should be_true 
    end

    it "should not verify user is pixter" do 
      @temp_listing.pixter?(@user2).should_not be_true 
    end
  end

  describe "editable" do 
    before do
      @pixter = create :pixi_user, user_type_code: 'PT'
      @admin = create :admin, confirmed_at: Time.now
      @support = create :support, confirmed_at: Time.now
      @user2 = FactoryGirl.create(:pixi_user, first_name: 'Lisa', last_name: 'Harden', email: 'lisaharden@pixitest.com') 
      @temp_listing = FactoryGirl.create(:temp_listing, seller_id: @user.id, pixan_id: @pixter.id) 
    end

    it "is editable" do 
      @temp_listing.editable?(@pixter).should be_true 
      @temp_listing.editable?(@user).should be_true 
      @temp_listing.editable?(@admin).should be_true 
      @temp_listing.editable?(@support).should be_true 
    end

    it "is not editable" do 
      @temp_listing.editable?(@user2).should_not be_true 
    end
  end

  describe "dup pixi" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "does not return new listing" do 
      listing = FactoryGirl.build :temp_listing, seller_id: user.id 
      listing.dup_pixi(true).should_not be_true
    end

    it 'returns new listing' do
      @new_listing = @temp_listing.dup_pixi(true)
      expect(@new_listing.pixi_id).to eq(@temp_listing.pixi_id)
      expect(TempListing.where(pixi_id: @new_listing.pixi_id).count).to eq(0)
      expect(Listing.where(pixi_id: @new_listing.pixi_id).count).to eq(1)
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
      @temp_listing.save
      expect(@temp_listing.pictures.count).to be > 1
      @dup_listing = @temp_listing.dup_pixi(true)
      expect(@dup_listing.title).not_to eq(@listing.title)
      expect(@dup_listing.status).to eq('active')
      expect(@dup_listing.price).to eq(999.99)
      expect(@dup_listing.wanted_count).to eq(1)
      expect(@dup_listing.liked_count).to eq(1)
      expect(@dup_listing.pictures.count).to be > 1
      expect(TempListing.where(pixi_id: @listing.pixi_id).count).to eq(0)
      expect(TempListing.where("title like 'Super%'").count).to eq(0)
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
      @temp_listing.delete_photo(@temp_listing.pictures.first.id)
      expect(@temp_listing.pictures.count).to eq(1)
      @dup_listing = @temp_listing.dup_pixi(true)
      expect(@dup_listing.title).not_to eq(@listing.title)
      expect(@dup_listing.status).to eq('active')
      expect(@dup_listing.price).to eq(999.99)
      expect(@dup_listing.wanted_count).to eq(1)
      expect(@dup_listing.liked_count).to eq(1)
      # expect(@dup_listing.pictures.count).to eq 1
      expect(TempListing.where(pixi_id: @listing.pixi_id).count).to eq(0)
      expect(TempListing.where("title like 'Super%'").count).to eq(0)
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
      # expect(@dup_listing.pictures.count).to eq 1
      expect(TempListing.where(pixi_id: @listing.pixi_id).count).to eq(0)
      expect(TempListing.where("title like 'Super%'").count).to eq(0)
      expect(Listing.where(pixi_id: @listing.pixi_id).count).to eq(1)
      expect(Listing.where("title like 'Super%'").count).to eq(1)
    end
  end

  describe "post to board" do
    let(:user) { FactoryGirl.create :pixi_user }
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
      temp_listing.delete_photo(5000).should_not be_true
    end

    it "deletes photo w/ one photo" do 
      pic = temp_listing.pictures.first
      temp_listing.delete_photo(pic.id, 0).should be_true
      expect(temp_listing.pictures(true).size).to eq 0
      temp_listing.should_not be_valid
    end

    it "should delete photo" do 
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save
      pic = temp_listing.pictures.first
      temp_listing.delete_photo(pic.id).should be_true
    end
  end

  describe 'premium?' do
    it 'should return true' do
      temp_listing = FactoryGirl.create(:temp_listing, category_id: @category.id) 
      temp_listing.premium?.should be_true
    end

    it 'should not return true' do
      @temp_listing.premium?.should_not be_true
    end
  end

  describe 'pictures' do
    before(:each) do
      @sr = @temp_listing.pictures.create FactoryGirl.attributes_for(:picture)
    end
				            
    it "should have pictures" do 
      @temp_listing.pictures.should include(@sr)
    end

    it "should not have too many pictures" do 
      20.times { @temp_listing.pictures.build FactoryGirl.attributes_for(:picture) }
      @temp_listing.save
      @temp_listing.should_not be_valid
    end

    it "should destroy associated pictures" do
      @temp_listing.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
    end  
  end  

  describe '.same_day?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Events', pixi_type: 'premium') 
      @temp_listing.category_id = @cat.id
    end

    it "should respond to same_day? method" do
      @temp_listing.should respond_to(:same_day?)
    end

    it "should be the same day" do
      @temp_listing.event_start_date = Date.today
      @temp_listing.event_end_date = Date.today
      @temp_listing.same_day?.should be_true
    end

    it "should not be the same day" do
      @temp_listing.event_start_date = Date.today
      @temp_listing.event_end_date = Date.today+1.day
      @temp_listing.same_day?.should be_false 
    end
  end

  describe 'sold?' do
    it 'should return true' do
      @temp_listing.status = 'sold'
      @temp_listing.sold?.should be_true
    end

    it 'should not return true' do
      @temp_listing.sold?.should_not be_true
    end
  end

  describe '.pending?' do
    it "is not pending" do
      @temp_listing.pending?.should be_false 
    end

    it "is pending" do
      @temp_listing.status = 'pending'
      @temp_listing.pending?.should be_true 
    end
  end

  describe '.denied?' do
    it "is not denied" do
      @temp_listing.denied?.should be_false 
    end

    it "is denied" do
      @temp_listing.status = 'denied'
      @temp_listing.denied?.should be_true 
    end
  end

  describe '.edit?' do
    it "is not edit" do
      @temp_listing.edit?.should be_false 
    end

    it "is edit" do
      @temp_listing.status = 'edit'
      @temp_listing.edit?.should be_true 
    end
  end

  describe '.event?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'event', pixi_type: 'premium') 
    end

    it "is not an event" do
      @temp_listing.event?.should be_false 
    end

    it "is an event" do
      @temp_listing.category_id = @cat.id
      @temp_listing.event?.should be_true 
    end
  end

  describe '.has_year?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'asset', pixi_type: 'premium') 
    end

    it "does not have a year" do
      @temp_listing.has_year?.should be_false 
    end

    it "has a year" do
      @temp_listing.category_id = @cat.id
      @temp_listing.has_year?.should be_true 
    end
  end

  describe '.job?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', category_type_code: 'employment', pixi_type: 'premium') 
    end

    it "is not a job" do
      @temp_listing.job?.should be_false 
    end

    it "is a job" do
      @temp_listing.category_id = @cat.id
      @temp_listing.job?.should be_true 
    end

    it "is not valid" do
      @temp_listing.category_id = @cat.id
      @temp_listing.should_not be_valid
    end

    it "is valid" do
      create :job_type
      @temp_listing.category_id = @cat.id
      @temp_listing.job_type_code = 'CT'
      @temp_listing.should be_valid
    end
  end

  describe '.free?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') 
    end

    it "is not free" do
      @temp_listing.category_id = @cat.id
      @temp_listing.free?.should be_false 
    end

    it "is free" do
      @temp_listing.free?.should be_true 
    end
  end

  describe "is not pixi_post" do 
    it { @temp_listing.pixi_post?.should_not be_true }
  end

  describe "is a pixi_post" do 
    before do 
      @pixan = FactoryGirl.create(:contact_user) 
      @temp_listing.pixan_id = @pixan.id 
    end
    it { @temp_listing.has_pixi_post?.should be_true }
  end

  describe 'contacts' do
    before(:each) do
      @sr = @temp_listing.contacts.create FactoryGirl.attributes_for(:contact)
    end
				            
    it "should have many contacts" do 
      @temp_listing.contacts.should include(@sr)
    end

    it "should destroy associated contacts" do
      @temp_listing.destroy
      [@sr].each do |s|
         Contact.find_by_id(s.id).should be_nil
       end
    end  
  end  

  describe 'site_address' do
    it 'has site address' do
      @site = create :site
      @contact = @site.contacts.create FactoryGirl.attributes_for(:contact)
      temp_listing = create :temp_listing, seller_id: @user.id, site_id: @site.id
      expect(temp_listing.site_address).to eq @contact.full_address
    end

    it 'has no site address' do
      expect(@temp_listing.site_address).to eq @temp_listing.site_name
    end
  end

  describe "find_pixi" do
    it 'finds a pixi' do
      expect(TempListing.find_pixi(@temp_listing.pixi_id)).not_to be_nil
    end

    it 'does not find pixi' do
      expect(TempListing.find_pixi(0)).to be_nil
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

  describe 'async_send_notifications' do
    let(:temp_listing) {create :temp_listing_with_transaction, seller_id: @user.id}
    let(:denied_listing) {create :temp_listing_with_transaction, seller_id: @user.id, status: 'denied'}

    def send_mailer model, msg
      @mailer = mock(UserMailer)
      UserMailer.stub!(:delay).and_return(@mailer)
      @mailer.stub(msg.to_sym).with(model).and_return(@mailer)
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
      }.to change {Listing.count}.by(1)
    end

    it 'adds listing and transaction' do
      temp_listing.status = 'approved'
      temp_listing.transaction.amt = 0.0
      expect {
	temp_listing.save!
      }.to change {Listing.count}.by(1)
      Listing.stub(:create).with(temp_listing.attributes).and_return(true)
      temp_listing.transaction.status.should == 'approved'
      temp_listing.transaction.status.should_not == 'pending'
    end

    it 'delivers the denied pixi message' do
      create :admin, email: PIXI_EMAIL
      temp_listing.status = 'denied'
      temp_listing.save!
      send_mailer temp_listing, 'send_denial'
      SystemMessenger.stub!(:send_system_message).with(@user, temp_listing, 'deny').and_return(true)
    end
  end

  describe '.start_date?' do
    it "has no start date" do
      @temp_listing.start_date?.should be_false
    end

    it "has a start date" do
      @temp_listing.event_start_date = Time.now
      @temp_listing.start_date?.should be_true
    end
  end

  describe 'format_date' do
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

  describe 'display_date' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :temp_listing, seller_id: user.id }

    it "does not show local updated date" do
      listing.updated_at = nil
      expect(listing.display_date(listing.updated_at)).to eq Time.now.strftime('%m/%d/%Y %l:%M %p')
    end

    it "show current updated date" do
      expect(listing.display_date(listing.updated_at)).to eq listing.updated_at.strftime('%m/%d/%Y %l:%M %p')
    end

    it "shows local updated date" do
      listing.lat, listing.lng = 35.1498, -90.0492
      expect(listing.display_date(listing.updated_at)).not_to eq Time.now.strftime('%m/%d/%Y %l:%M %p')
      expect(listing.display_date(listing.updated_at)).not_to eq listing.updated_at.strftime('%m/%d/%Y %l:%M %p')
    end
  end

  describe "date validations" do
    before do
      @cat = FactoryGirl.create(:category, name: 'Event', pixi_type: 'premium') 
      @temp_listing.category_id = @cat.id
      @temp_listing.event_end_date = Date.today+3.days 
      @temp_listing.event_start_time = Time.now+2.hours
      @temp_listing.event_end_time = Time.now+3.hours
    end

    describe 'start date' do
      it "has valid start date" do
        @temp_listing.event_start_date = Date.today+2.days
        @temp_listing.should be_valid
      end

      it "should reject a bad start date" do
        @temp_listing.event_start_date = Date.today-2.days
        @temp_listing.should_not be_valid
      end

      it "should not be valid without a start date" do
        @temp_listing.event_start_date = nil
        @temp_listing.should_not be_valid
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
        @temp_listing.should be_valid
      end

      it "should reject a bad end date" do
        @temp_listing.event_end_date = ''
        @temp_listing.should_not be_valid
      end

      it "should reject end date < start date" do
        @temp_listing.event_end_date = Date.today-2.days
        @temp_listing.should_not be_valid
      end

      it "should not be valid without a end date" do
        @temp_listing.event_end_date = nil
        @temp_listing.should_not be_valid
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
        @temp_listing.should be_valid
      end

      it "should reject a bad start time" do
        @temp_listing.event_start_time = ''
        @temp_listing.should_not be_valid
      end

      it "should not be valid without a start time" do
        @temp_listing.event_start_time = nil
        @temp_listing.should_not be_valid
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
        @temp_listing.should be_valid
      end

      it "should reject a bad end time" do
        @temp_listing.event_end_time = ''
        @temp_listing.should_not be_valid
      end

      it "should reject end time < start time" do
        @temp_listing.event_end_date = @temp_listing.event_start_date
        @temp_listing.event_end_time = Time.now.advance(:hours => -2)
        @temp_listing.should_not be_valid
      end

      it "should not be valid without a end time" do
        @temp_listing.event_end_time = nil
        @temp_listing.should_not be_valid
      end
    end
  end

  describe "get_by_city" do
    it "should get listings" do
      @listings = FactoryGirl.create(:temp_listing)
      @listings.status = 'pending'
      @listings.save
      TempListing.get_by_city(0, 1, 1, false).should_not include @listings
      TempListing.get_by_city(@listings.category_id, @listings.site_id, 1, false).should_not be_empty
    end
  end

  describe "check_category_and_location" do
    before do
      @listings = FactoryGirl.create(:temp_listing)
      @listings.status = 'pending'
      @listings.save
    end

    it "should get all listings of given status if category and location are not specified" do
      TempListing.check_category_and_location('pending', nil, nil).should_not be_empty
    end

    it "should get listing when category and location are specified" do      
      TempListing.check_category_and_location('pending', @listings.category_id, @listings.site_id).should_not be_empty
    end

    it "should not return anything if no listings meet the parameters" do
      TempListing.check_category_and_location('removed', 100, 900).should be_empty
    end
  end

  describe '.event_type' do
    before do
      @etype = FactoryGirl.create(:event_type, code: 'party', description: 'Parties, Galas, and Gatherings')
      @cat = FactoryGirl.create(:category, name: 'Events', category_type_code: 'event')
      @listing1 = FactoryGirl.create(:temp_listing, seller_id: @user.id)
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
      expect(@temp_listing.event_type_code).not_to eq 'party'
    end

    it "shows event_type description" do
      expect(@listing1.event_type_descr).to eq @etype.description.titleize
    end

    it "does not show event_type description" do
      expect(@temp_listing.event_type_descr).to be_nil
    end
  end
end
