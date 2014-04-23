require 'spec_helper'

describe PixiPost do
  before(:each) do
    @user = create(:pixi_user) 
    @pixi_post_zip = create(:pixi_post_zip)
    @pixi_post = @user.pixi_posts.build FactoryGirl.attributes_for(:pixi_post) 
  end

  subject { @pixi_post }

  it { should respond_to(:user_id) }
  it { should respond_to(:preferred_date) }
  it { should respond_to(:preferred_time) }
  it { should respond_to(:alt_time) }
  it { should respond_to(:alt_date) }
  it { should respond_to(:value) }
  it { should respond_to(:quantity) }
  it { should respond_to(:description) }
  it { should respond_to(:address) }
  it { should respond_to(:address2) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zip) }
  it { should respond_to(:pixan_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:appt_date) }
  it { should respond_to(:appt_time) }
  it { should respond_to(:completed_time) }
  it { should respond_to(:completed_date) }
  it { should respond_to(:set_flds) }
  it { should respond_to(:home_phone) }
  it { should respond_to(:mobile_phone) }
  it { should respond_to(:comments) }
  it { should respond_to(:editor_id) }
  it { should respond_to(:pixan_name) }
  it { should respond_to(:country) }
  it { should respond_to(:zip_service_area) }

  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:preferred_time) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:address) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:state) }
  it { should validate_presence_of(:zip) }
  it { should ensure_length_of(:address).is_at_most(50) }
  it { should ensure_length_of(:city).is_at_most(30) }
  it { should ensure_length_of(:zip).is_equal_to(5) }
  it { should validate_presence_of(:home_phone) }
  it { should ensure_length_of(:home_phone).is_at_least(10).is_at_most(15) }
  it { should ensure_length_of(:mobile_phone).is_at_least(10).is_at_most(15) }
  it { should_not allow_value('4157251111abcdef').for(:home_phone) }
  it { should allow_value(4157251111).for(:home_phone) }
  it { should_not allow_value(7251111).for(:home_phone) }
  it { should allow_value(4157251111).for(:mobile_phone) }
  it { should_not allow_value(7251111).for(:mobile_phone) }
  it { should allow_value(41572).for(:zip) }
  it { should_not allow_value(725).for(:zip) }

  it { should have_db_column(:pixi_id) }
  it { should have_db_index(:pixi_id) }

  it { should validate_numericality_of(:quantity).is_greater_than(0) }
  it { should validate_numericality_of(:value).is_greater_than_or_equal_to(50) }
  it { should validate_numericality_of(:value).is_less_than_or_equal_to(MAX_PIXI_AMT.to_f) }
  it { should allow_value(400).for(:value) }
  it { should_not allow_value(30).for(:value) }
  it { should_not allow_value(200000).for(:value) }
  it { should belong_to(:user) }
  it { should belong_to(:listing).with_foreign_key('pixi_id') }
  it { should belong_to(:pixan).with_foreign_key('pixan_id') }

  describe "active pixi posts" do
    before { @user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post)}
    it { PixiPost.active.should_not be_nil } 
  end

  describe "inactive pixi posts" do
    before { @user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post, status: 'inactive') }
    it { PixiPost.active.should be_empty } 
  end

  describe "get by status" do
    it "get_by_status should not include active posts" do
      @user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post) 
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
      expect(@pixi_post.seller_name).not_to eq(@user.name)
    end
  end

  describe "seller first name" do 
    it { @pixi_post.seller_first_name.should == @user.first_name } 

    it "should not find correct seller first_name" do 
      @pixi_post.user_id = 100 
      expect(@pixi_post.seller_first_name).not_to eq(@user.first_name)
    end
  end

  describe "seller email" do 
    it { @pixi_post.seller_email.should == @user.email } 

    it "should not find correct seller email" do 
      @pixi_post.user_id = 100 
      expect(@pixi_post.seller_email).not_to eq(@user.email)
    end
  end

  describe "owner" do 
    it "should verify user is owner" do 
      @pixi_post.owner?(@user).should be_true 
    end

    it "should not verify user is owner" do 
      other_user = FactoryGirl.create :contact_user
      @pixi_post.owner?(other_user).should_not be_true 
    end
  end

  describe 'has_address?' do
    it 'should return true' do
      @pixi_post.has_address?.should be_true
    end

    it 'should not return true' do
      pixi_post = FactoryGirl.build :pixi_post, address: '', city: ''
      pixi_post.has_address?.should_not be_true
    end
  end
  
  describe "load pixipost" do
    it "loads new pixipost w/ existing address" do
      contact_user = FactoryGirl.create :contact_user 
      pp = PixiPost.load_new(contact_user, '90201')
      expect(pp.address).not_to be_nil
    end

    it "loads new pixipost w/o existing address" do
      create(:pixi_post_zip, zip: 90204)
      contact_user = FactoryGirl.create :contact_user 
      pp = PixiPost.load_new(contact_user, '90204')
      expect(pp.address).to be_nil
    end

    it "does not load new pixipost" do
      PixiPost.load_new(nil, '90201').should be_nil
    end
  end

  describe '.has_pixan?' do
    it "has no pixan" do
      @pixi_post.has_pixan?.should be_false
    end

    it "has a pixan" do
      pixan = FactoryGirl.create :pixi_user
      @pixi_post.pixan_id = pixan.id
      @pixi_post.has_pixan?.should be_true
    end
  end

  describe 'has_pixi?' do
    it 'should not return true' do
      @pixi_post.has_pixi?.should_not be_true
    end

    it 'should return true' do
      listing = FactoryGirl.create :listing, seller_id: @user.id
      pixi_post = FactoryGirl.build :pixi_post, pixi_id: listing.id
      pixi_post.has_pixi?.should be_true
    end
  end

  describe 'has_appt?' do
    it 'should not return true' do
      @pixi_post.has_appt?.should_not be_true
    end

    it 'should return true' do
      pixi_post = FactoryGirl.build :pixi_post, appt_date: Date.today+1.day
      pixi_post.has_appt?.should be_true
    end
  end

  describe 'is_completed?' do
    it 'should not return true' do
      @pixi_post.is_completed?.should_not be_true
    end

    it 'should return true' do
      pixi_post = FactoryGirl.build :pixi_post, completed_date: Date.today+1.day
      pixi_post.is_completed?.should be_true
    end
  end

  describe 'is_admin?' do
    it 'should not return true' do
      @pixi_post.is_admin?.should_not be_true
    end

    it 'should return true' do
      pixi_post = FactoryGirl.build :pixi_post, completed_date: Date.today+1.day, appt_date: Date.today+1.day
      pixi_post.is_admin?.should be_true
    end
  end

  describe 'has_comments?' do
    it 'does not return true' do
      @pixi_post.has_comments?.should_not be_true
    end

    it 'returns true' do
      pixi_post = FactoryGirl.build :pixi_post, comments: 'ask for julie'
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

  describe 'set_flds' do
    it "sets status to active" do
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, status: nil
      @post.save
      @post.status.should == 'active'
    end

    it "does not set status to active" do
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, status: 'inactive'
      @post.save
      @post.status.should_not == 'active'
    end

    it "sets status to scheduled" do
      @pixan = FactoryGirl.create :pixi_user
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Date.today+3.days, 
        appt_time: Time.now+3.days
      @post.save
      @post.status.should == 'scheduled'
    end

    it "sets status to completed" do
      @listing = create :listing, seller_id: @user.id
      @pixan = create :pixi_user
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days, 
        appt_time: Time.now+3.days, completed_date: Time.now+3.days, pixi_id: @listing.pixi_id
      @post.save
      @post.status.should_not == 'scheduled'
      expect(@post.status).to eq('completed')
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
        @pixi_post.preferred_date = Date.today+2.days
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
        @pixi_post.preferred_date = Date.today+2.days 
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
        @pixan = FactoryGirl.create :pixi_user
        @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: @pixan.id
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
        @pixi = FactoryGirl.create :listing, seller_id: @user.id
        @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixi_id: @pixi.id
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

      it "has valid completed date w/ old appt date" do
        @pixan = FactoryGirl.create :pixi_user
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
    let(:pixan) { FactoryGirl.create :pixi_user }
    it "checks appt date" do
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: pixan.id, appt_date: Date.today+3.days 
      @pixi_post.should be_valid
    end

    it "checks for missing appt date" do
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: pixan.id
      @post.should_not be_valid
    end
  end

  describe 'pixi_id' do
    let(:pixan) { FactoryGirl.create :pixi_user }
    let(:listing) { FactoryGirl.create :listing, seller_id: @user.id }

    it "checks completed date" do
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: pixan.id, appt_date: Time.now+3.days, 
        completed_date: Time.now+3.days, pixi_id: listing.pixi_id, appt_time: Time.now+3.days
      @post.should be_valid
    end

    it "checks for missing completed date" do
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: pixan.id, pixi_id: listing.pixi_id
      @post.should_not be_valid
    end
  end

  describe "zip service area" do 
    let(:pixi_post) { FactoryGirl.build :pixi_post, zip: '94720' }
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
end
