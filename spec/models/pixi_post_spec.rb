require 'spec_helper'

describe PixiPost do
  before(:all) do
    @user = create(:pixi_user) 
    @buyer = create(:pixi_user) 
    @pixan = create(:pixi_user) 
    @pixi_post_zip = create(:pixi_post_zip)
  end
  before(:each) do
    @pixi_post = @user.pixi_posts.build attributes_for(:pixi_post) 
  end

  def add_invoice item
    @invoice = @user.invoices.build attributes_for(:invoice, buyer_id: @buyer.id)
    @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: item.pixi_id 
    @invoice.save!
  end

  def add_post
    @listing = create(:listing, seller_id: @user.id)
    @pixi_post.pixan_id = @pixan.id
    @pixi_post.completed_date = Time.now+3.days
    @pixi_post.appt_date = @pixi_post.appt_time = Time.now-3.days
    @pixi_post.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing.pixi_id 
    @pixi_post.save!
  end

  subject { @pixi_post }

  describe 'post_attributes', base: true do
    it { should respond_to(:user_id) }
    it { should respond_to(:preferred_date) }
    it { should respond_to(:preferred_time) }
    it { should respond_to(:alt_time) }
    it { should respond_to(:alt_date) }
    it { should respond_to(:value) }
    it { should respond_to(:quantity) }
    it { should respond_to(:description) }
    it { should respond_to(:pixan_id) }
    it { should respond_to(:appt_date) }
    it { should respond_to(:appt_time) }
    it { should respond_to(:completed_time) }
    it { should respond_to(:completed_date) }
    it { should respond_to(:set_flds) }
    it { should respond_to(:comments) }
    it { should respond_to(:editor_id) }
    it { should respond_to(:pixan_name) }
    it { should respond_to(:zip_service_area) }

    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:preferred_time) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:value) }

    it { should belong_to(:user) }
    it { should belong_to(:pixan).with_foreign_key('pixan_id') }
    it { should have_many(:pixi_post_details) }
    it { should have_many(:listings).through(:pixi_post_details) }

    it_behaves_like "an address", @post, :pixi_post

    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(50) }
    it { should validate_numericality_of(:value).is_less_than_or_equal_to(MAX_PIXI_AMT.to_f) }
    it { should allow_value(400).for(:value) }
    it { should_not allow_value(30).for(:value) }
    it { should_not allow_value(200000).for(:value) }
  end

  describe "active pixi posts" do
    before { @user.pixi_posts.create attributes_for(:pixi_post)}
    it { PixiPost.active.should_not be_nil } 
  end

  describe "inactive pixi posts" do
    before { @user.pixi_posts.create attributes_for(:pixi_post, status: 'inactive') }
    it { PixiPost.active.should be_empty } 
  end

  describe "get by status" do
    it "get_by_status should not include active posts" do
      @user.pixi_posts.create attributes_for(:pixi_post) 
      PixiPost.get_by_status('active').should_not be_empty 
    end

    it "get_by_status should not include inactive posts" do
      PixiPost.get_by_status('inactive').should_not == @pixi_post 
    end
  end

  describe "pixter name" do 
    it { @pixi_post.pixter_name.should be_nil } 

    it "should not find correct pixter name" do 
      pixan = create(:pixi_user)
      @pixi_post.pixan_id = pixan.id 
      expect(@pixi_post.pixter_name).to eq(pixan.name)
    end
  end

  describe "seller name" do 
    it { @pixi_post.seller_name.should == @user.name } 

    it "should not find correct seller name" do 
      @pixi_post.user_id = 100 
      @pixi_post.save
      @pixi_post.reload
      expect(@pixi_post.seller_name).not_to eq(@user.name)
    end
  end

  describe "seller first name" do 
    it { @pixi_post.seller_first_name.should == @user.first_name } 

    it "should not find correct seller first_name" do 
      @pixi_post.user_id = 100
      @pixi_post.save
      @pixi_post.reload
      expect(@pixi_post.seller_first_name).not_to eq(@user.first_name)
    end
  end

  describe "seller email" do 
    it { @pixi_post.seller_email.should == @user.email } 

    it "should not find correct seller email" do 
      @pixi_post.user_id = 100
      @pixi_post.save
      @pixi_post.reload
      expect(@pixi_post.seller_email).not_to eq(@user.email)
    end
  end

  describe "owner" do 
    it "should verify user is owner" do 
      @pixi_post.owner?(@user).should be_true 
    end

    it "should not verify user is owner" do 
      other_user = create :contact_user
      @pixi_post.owner?(other_user).should_not be_true 
    end
  end

  describe 'has_address?' do
    it 'should return true' do
      @pixi_post.has_address?.should be_true
    end

    it 'should not return true' do
      pixi_post = build :pixi_post, address: '', city: ''
      pixi_post.has_address?.should_not be_true
    end
  end
  
  describe "load pixipost" do
    it "loads new pixipost w/ existing address" do
      contact_user = create :contact_user 
      pp = PixiPost.load_new(contact_user, '90201')
      expect(pp.address).not_to be_nil
    end

    it "loads new pixipost w/o existing address" do
      create(:pixi_post_zip, zip: 90204)
      contact_user = create :contact_user 
      pp = PixiPost.load_new(contact_user, '90204')
      expect(pp.address).to be_nil
    end

    it "does not load new pixipost" do
      PixiPost.load_new(nil, '90201').should_not be_nil
    end
  end

  describe '.has_pixan?' do
    it "has no pixan" do
      @pixi_post.has_pixan?.should be_false
    end

    it "has a pixan" do
      pixan = create :pixi_user
      @pixi_post.pixan_id = pixan.id
      @pixi_post.has_pixan?.should be_true
    end
  end

  describe 'has_pixi?' do
    it 'should not return true' do
      @pixi_post.has_pixi?.should_not be_true
    end

    it 'should return true' do
      listing = create :listing, seller_id: @user.id
      @pixi_post.completed_date = Date.today
      @pixi_post.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: listing.pixi_id 
      @pixi_post.save!
      @pixi_post.has_pixi?.should be_true
    end
  end

  describe 'has_appt?' do
    it 'should not return true' do
      @pixi_post.has_appt?.should_not be_true
    end

    it 'should return true' do
      pixi_post = build :pixi_post, appt_date: Date.today+1.day
      pixi_post.has_appt?.should be_true
    end
  end

  describe 'is_completed?' do
    it 'should not return true' do
      @pixi_post.is_completed?.should_not be_true
    end

    it 'should return true' do
      pixi_post = build :pixi_post, completed_date: Date.today+1.day
      pixi_post.is_completed?.should be_true
    end
  end

  describe 'is_admin?' do
    it 'should not return true' do
      @pixi_post.is_admin?.should_not be_true
    end

    it 'should return true' do
      pixi_post = build :pixi_post, completed_date: Date.today+1.day, appt_date: Date.today+1.day
      pixi_post.is_admin?.should be_true
    end
  end

  describe 'has_comments?' do
    it 'does not return true' do
      @pixi_post.has_comments?.should_not be_true
    end

    it 'returns true' do
      pixi_post = build :pixi_post, comments: 'ask for julie'
      pixi_post.has_comments?.should be_true
    end
  end

  describe 'get_time' do
    it 'should not return true' do
      @pixi_post.get_time('test').should_not be_true
    end

    it 'should return true' do
      @pixi_post.get_time('preferred_time').should be_true
    end
  end

  describe 'get_date' do
    it 'should not return true' do
      @pixi_post.get_date('test').should_not be_true
    end

    it 'should return true' do
      @pixi_post.get_date('preferred_date').should be_true
    end
  end

  describe 'reschedule' do
    before do
      @pixan = create :pixi_user
      @post = @user.pixi_posts.create attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Date.today+5.days, 
        appt_time: Time.now+5.days, comments: 'use the back door'
      @pid = @post.id
    end

    it 'recreates post' do
      @new_post = PixiPost.reschedule(@pid)
      expect(@new_post.user_id).not_to be_nil
      expect(@new_post.description).not_to be_nil
      expect(@new_post.alt_date).to be_nil
      expect(@new_post.preferred_date).to be_nil
      expect(@new_post.appt_date).to be_nil
      expect(@new_post.pixan_id).to be_nil
      expect(@new_post.comments).to be_nil
      expect(PixiPost.where(id: @pid).count).to eq(0)
    end

    it 'does not recreate post' do
      @new_post = PixiPost.reschedule(0)
      expect(@new_post.description).to be_nil
      expect(PixiPost.where(id: @pid).count).to eq(1)
    end
  end

  describe 'set_flds' do
    it "sets status to active" do
      @post = @user.pixi_posts.build attributes_for :pixi_post, status: nil
      @post.save
      @post.status.should == 'active'
    end

    it "does not set status to active" do
      @post = @user.pixi_posts.build attributes_for :pixi_post, status: 'inactive'
      @post.save
      @post.status.should_not == 'active'
    end

    it "sets status to scheduled" do
      @pixan = create :pixi_user
      @post = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Date.today+3.days, 
        appt_time: Time.now+3.days
      @post.save
      @post.status.should == 'scheduled'
    end

    it "sets status to completed" do
      @listing = create :listing, seller_id: @user.id
      @pixan = create :pixi_user
      @post = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days, 
        appt_time: Time.now+3.days, completed_date: Time.now+3.days
      @post.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing.pixi_id 
      @post.save
      @post.status.should_not == 'scheduled'
      expect(@post.status).to eq('completed')
    end
  end

  describe "seller posts" do 
    it "includes seller posts" do
      @user.pixi_posts.create attributes_for(:pixi_post) 
      expect(PixiPost.all.count).to eq(1)
      PixiPost.get_by_seller(@user).should_not be_empty  
    end
      
    it { PixiPost.get_by_seller(0).should_not include @pixi_post } 
  end

  describe "pixter posts" do 
    it { PixiPost.get_by_pixter(0).should_not include @pixi_post } 

    it "includes pixter posts" do 
      @pixi_post.appt_date = @pixi_post.appt_time = Time.now+3.days
      @pixi_post.pixan_id = 1
      @pixi_post.save
      PixiPost.get_by_pixter(1).should_not be_empty  
    end
  end

  describe "date validations" do
    before do
      @pixi_post.alt_date = Date.today+3.days 
      @pixi_post.preferred_time = Time.now+2.hours
      @pixi_post.alt_time = Time.now+3.hours
    end

    describe 'preferred date' do
      it "has valid preferred date" do
        @pixi_post.preferred_date = Date.today+4.days
        @pixi_post.should be_valid
      end

      it "does not reject a old preferred date" do
        @pixan = create :pixi_user
        @pixi_post.preferred_date = Date.today-1.day
        @pixi_post.appt_date = @pixi_post.appt_time = Time.now+3.days
	@pixi_post.pixan_id = @pixan.id
        @pixi_post.should be_valid
      end

      it "rejects a bad preferred date" do
        @pixi_post.preferred_date = Date.today-1.day
        @pixi_post.should_not be_valid
      end

      it "rejects a bad preferred time" do
        @pixi_post.preferred_time = nil
        @pixi_post.should_not be_valid
      end

      it "is not be valid without a preferred date" do
        @pixi_post.preferred_date = nil
        @pixi_post.should_not be_valid
      end
    end

    describe 'alternate date' do
      before do
        @pixi_post.preferred_date = Date.today+4.days 
        @pixi_post.preferred_time = Time.now+2.hours
        @pixi_post.alt_time = Time.now+3.hours
      end

      it "has valid alternate date" do
        @pixi_post.alt_date = Date.today+3.days
        @pixi_post.should be_valid
      end

      it "does not reject a old alt date" do
        @pixan = create :pixi_user
        @pixi_post.alt_date = Date.today-1.day
        @pixi_post.appt_date = @pixi_post.appt_time = Time.now+3.days
	@pixi_post.pixan_id = @pixan.id
        @pixi_post.should be_valid
      end

      it "has invalid alternate time" do
        @pixi_post.alt_date = Date.today+3.days
        @pixi_post.alt_time = nil
        @pixi_post.should_not be_valid
      end

      it "should reject a bad alternate date" do
        @pixi_post.alt_date = Date.today-1.day
        @pixi_post.should_not be_valid
      end
    end

    describe 'appt date' do
      before do
        @pixan = create :pixi_user
        @post = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: @pixan.id
      end

      it "has valid appt date" do
        @post.appt_date = @post.appt_time = Time.now+3.days
        @post.should be_valid
      end

      it "has valid appt date w/ old preferred date" do
        @post.appt_date = @post.appt_time = Time.now+3.days
        @post.preferred_date = Time.now-3.days
        @post.should be_valid
      end

      it "rejects a bad or missing appt date" do
        @post.should_not be_valid
      end

      it "has invalid appt time" do
        @pixi_post.appt_date = Date.today+3.days
        @pixi_post.appt_time = nil
        @pixi_post.should_not be_valid
      end

      it "rejects a missing pixan id" do
        @post.appt_date = Date.today+3.days
	@post.pixan_id = nil
        @post.should_not be_valid
      end
    end

    describe 'completed date' do
      before do
        @pixi = create :listing, seller_id: @user.id
        @post = @user.pixi_posts.build attributes_for :pixi_post
        @post.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @pixi.pixi_id 
      end

      it "has valid completed date" do
        @post.completed_date = Date.today+3.days
        @post.should be_valid
      end

      it "has valid completed date w/ old preferred date" do
        @post.completed_date = Time.now+3.days
        @post.preferred_date = Time.now-3.days
        @post.should be_valid
      end

      it "has valid completed date w/ old alt date" do
        @post.completed_date = Time.now+3.days
        @post.alt_date = Time.now-3.days
        @post.should be_valid
      end

      it "has valid old completed date w/ old alt date" do
        @post.completed_date = Time.now-3.days
        @post.alt_date = Time.now-3.days
        @post.should be_valid
      end

      it "has valid completed date w/ old appt date" do
        @pixan = create :pixi_user
	@post.pixan_id = @pixan.id
        @post.completed_date = Time.now+3.days
        @post.appt_date = @post.appt_time = Time.now-3.days
        @post.should be_valid
      end

      it "rejects a bad or missing completed date" do
        @post.should_not be_valid
      end
    end
  end

  describe 'pixan_id' do
    let(:pixan) { create :pixi_user }
    it "checks appt date" do
      @post = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: pixan.id, appt_date: Date.today+3.days 
      @pixi_post.should be_valid
    end

    it "checks for missing appt date" do
      @post = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: pixan.id
      @post.should_not be_valid
    end
  end

  describe 'pixi_id' do
    let(:pixan) { create :pixi_user }
    let(:listing) { create :listing, seller_id: @user.id }

    it "checks completed date" do
      @post = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: pixan.id, appt_date: Time.now+3.days, 
        completed_date: Time.now+3.days, appt_time: Time.now+3.days
      @post.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: listing.pixi_id 
      @post.should be_valid
    end

    it "checks for missing completed date" do
      @post = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: pixan.id
      @post.should_not be_valid
    end

    it "checks for missing pixi" do
      @post = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: pixan.id, appt_date: Time.now+3.days, 
        completed_date: Time.now+3.days, appt_time: Time.now+3.days
      @post.should_not be_valid
    end
  end

  describe "zip service area" do 
    let(:pixi_post) { build :pixi_post, zip: '94720' }
    it { @pixi_post.should be_valid }

    it "should not save w/o valid zip" do 
      pixi_post.save
      pixi_post.should_not be_valid 
    end
  end 

  describe "full address" do
    it 'has address' do
      addr = [@pixi_post.address, @pixi_post.city, @pixi_post.state].compact.join(', ') + ' ' + [@pixi_post.zip, @pixi_post.country].compact.join(', ')
      expect(@pixi_post.full_address).to eq(addr)
    end

    it 'has no address' do
      @pixi_post.address = @pixi_post.city = @pixi_post.state = @pixi_post.zip = @pixi_post.country = nil
      expect(@pixi_post.full_address).to be_empty
    end
  end

  describe "item title and value" do
    let(:pixan) { create :pixi_user }
    context 'has title and value' do
      before { add_post }
      it { expect(@pixi_post.item_title).not_to be_nil }
      it { expect(@pixi_post.listing_value).not_to be_nil }
    end

    context "does not have item title or value" do
      it { expect(@pixi_post.item_title).to be_nil }
      it { expect(@pixi_post.listing_value).to eq 0.0 }
    end
  end

  describe "item sale value and date", invoice: true do
    let(:pixan) { create :pixi_user }
    before :each do 
       @listing = create(:listing, seller_id: @user.id)
       @account = @user.bank_accounts.create attributes_for :bank_account
       add_invoice @listing
    end

    context 'sold' do
      before :each do
        @pixi_post.pixan_id = pixan.id
        @pixi_post.completed_date = Time.now+3.days
        @pixi_post.appt_date = @pixi_post.appt_time = Time.now-3.days
        @pixi_post.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing.pixi_id 
        @pixi_post.save!
        @invoice.update_attribute(:status, 'paid')
      end
      it { expect(@pixi_post.sale_value).to eq @details.subtotal }
      it { expect(@pixi_post.sale_date.to_date).to eq @invoice.created_at.to_date }
      it { expect(@pixi_post.any_sold?).to be_true }
      it { expect(@pixi_post.revenue).to eq (@details.subtotal * PXB_TXN_PERCENT * PIXTER_PERCENT) }
      it { expect(@pixi_post.get_val('sale_value')).to eq @details.subtotal }
    end

    context 'not sold' do
      it { expect(@pixi_post.sale_value).not_to eq @listing.price }
      it { expect(@pixi_post.sale_date).not_to eq @invoice.created_at }
      it { expect(@pixi_post.any_sold?).not_to be_true }
      it { expect(@pixi_post.revenue).to eq 0.0 }
      it { expect(@pixi_post.get_val('revenue')).to eq 'Not sold yet' }
    end
  end

  describe 'pixter_report', invoice: true do
    include ResetDate
    let(:user) { create :pixi_user }
    before :each do
      @listing_completed = create :listing, seller_id: user.id, pixan_id: @user.id
      @listing_sold = create :listing, seller_id: user.id, pixan_id: @user.id, status: 'sold'
      add_invoice @listing_sold
      @completed = user.pixi_posts.build attributes_for :pixi_post, pixan_id: @user.id, appt_date: Time.now,
              appt_time: Time.now, completed_date: Time.now, description: 'rocking chair', status: 'completed'
      @completed.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing_completed.pixi_id 
      @completed.save!
      @sold = user.pixi_posts.build attributes_for :pixi_post, pixan_id: @user.id, appt_date: Time.now,
              appt_time: Time.now, completed_date: Time.now, description: 'rocking chair', status: 'sold'
      @sold.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing_sold.pixi_id 
      @sold.save!
    end

    it 'returns all pixter report data' do
      start_dt, end_dt = ResetDate::get_date_range 'This Year'
      expect(PixiPost.pixter_report(start_dt, end_dt, nil)).not_to be_nil
    end

    it 'returns user pixter report data' do
      start_dt, end_dt = ResetDate::get_date_range 'This Year'
      expect(PixiPost.pixter_report(start_dt, end_dt, @user)).not_to be_nil
    end

    it 'does not return all pixter report data' do
      start_dt, end_dt = Date.tomorrow, Date.tomorrow
      expect(PixiPost.pixter_report(start_dt, end_dt, nil)).to be_blank
    end

    it 'does not return user pixter report data' do
      start_dt, end_dt = ResetDate::get_date_range 'This Year'
      expect(PixiPost.pixter_report(start_dt, end_dt, user.id)).to be_blank
    end
  end
  
  describe 'process_request' do
    before :each do
      add_post
    end

    it 'adds ppx pixi points' do
      expect(@user.user_pixi_points.count).not_to eq(0)
      @user.user_pixi_points.find_by_code('ppx').code.should == 'ppx'
      @user.user_pixi_points.find_by_code('app').should be_nil
    end

    it 'updates contact info' do
      @post = @user.pixi_posts.build FactoryGirl.attributes_for(:pixi_post, status: 'active')
      @post.save!
      @post.reload
      @post.user.contacts[0].address.should == @post.address 
    end

    it 'delivers approved pixi message' do
      create :admin, email: PIXI_EMAIL
      send_mailer @pixi_post, 'send_pixipost_request'
    end

    it 'delivers reposted pixi message' do
      create :admin, email: PIXI_EMAIL
      send_mailer @pixi_post, 'send_pixipost_request_internal'
    end
  end
  
  describe 'send_appt_notice' do
    before :each do
      @pixi_post.pixan_id = @pixan.id
      @pixi_post.appt_date = @pixi_post.appt_time = Time.now+3.days
      @pixi_post.save!
    end

    it 'delivers reposted pixi message' do
      create :admin, email: PIXI_EMAIL
      send_mailer @pixi_post, 'send_pixipost_request_internal'
    end
  end

  def set_attr uid
    {"preferred_date"=>Date.today + 5.days, "preferred_time"=>"13:00:00", "alt_date"=>"", "alt_time"=>"12:00:00", 
      "quantity"=>"2", "value"=>"200.0", "description"=>"xbox 360 box.", "address"=>"123 Elm", "address2"=>"", "city"=>"LA", "state"=>"CA", 
      "zip"=>"90201", "home_phone"=>"4155551212", "mobile_phone"=>"", "user_id"=>"#{uid}"}
  end

  describe 'add_post' do
    it 'has user id' do
      @post = PixiPost.add_post(set_attr(@user.id), @user)
      @post.save!
      expect(@post.user_id).to eq @user.id
    end
    it 'has no user id' do
      expect(PixiPost.add_post(set_attr(''), User.new).user_id).not_to eq @user.id
    end
  end

  describe 'listing_tokens' do
    before :each, run: true do
      @listing = create :listing, seller_id: @user.id
    end
    it 'sets tokens', run: true do
      @pixi_post.listing_tokens=["OBssx4fDyEFs65220Ouslw", "#{@listing.pixi_id}", ""]
      expect(@pixi_post.pixi_post_details.size).to eq 1
    end
    it 'gets tokens' do
      add_post
      expect(@pixi_post.listing_tokens).to include @listing.pixi_id
    end
  end

  describe "exporting as CSV" do
    it "exports data as CSV file" do
      csv_string = @pixi_post.as_csv
      csv_string.keys.should =~ ["Post Date", "Item Title", "Customer", "Pixter", "Sale Date", "List Value", "Sale Amount", "Pixter Revenue"]
      csv_string.values.should =~ [@pixi_post.completed_date, @pixi_post.item_title, @pixi_post.seller_name, @pixi_post.pixter_name,
                                   @pixi_post.get_val('sale_date'), @pixi_post.listing_value, @pixi_post.get_val('sale_value'), 
                                   @pixi_post.get_val('revenue')]
    end

    it "does not export any pixi_post data" do
      post = build :pixi_post
      csv = post.as_csv
      csv.values.should include(nil)
    end
  end
end
