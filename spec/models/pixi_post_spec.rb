require 'spec_helper'

describe PixiPost do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
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
  it { should ensure_length_of(:zip).is_at_least(5).is_at_most(12) }

  it { should have_db_column(:pixi_id) }
  it { should have_db_index(:pixi_id) }

  it { should validate_numericality_of(:quantity).is_greater_than(0) }
  it { should validate_numericality_of(:value).is_greater_than_or_equal_to(50) }
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

  describe "should find correct seller name" do 
    it { @pixi_post.seller_name.should == @user.name } 
  end

  describe "should not find correct seller name" do 
    before { @pixi_post.seller_id = 100 }
    it { @pixi_post.seller_name.should be_nil } 
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
    it "should load new pixipost" do
      contact_user = FactoryGirl.create :contact_user 
      PixiPost.load_new(contact_user).should_not be_nil
    end

    it "should not load new pixipost" do
      PixiPost.load_new(nil).should be_nil
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

  describe 'get_time' do
    it 'should not return true' do
      @pixi_post.get_time('test').should_not be_true
    end

    it 'should return true' do
      @pixi_post.get_time('preferred_time').should be_true
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
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Date.today+3.days
      @post.save
      @post.status.should == 'scheduled'
    end

    it "sets status to scheduled" do
      @pixan = FactoryGirl.create :pixi_user
      @post = @user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Date.today+3.days, 
        completed_date: Date.today+3.days
      @post.save
      @post.status.should_not == 'scheduled'
      @post.status.should == 'completed'
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

      it "should reject a bad preferred date" do
        @pixi_post.preferred_date = Date.today-1.day
        @pixi_post.should_not be_valid
      end

      it "should reject a bad preferred time" do
        @pixi_post.preferred_time = nil
        @pixi_post.should_not be_valid
      end

      it "should not be valid without a preferred date" do
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
        @post.appt_date = Date.today+3.days
        @post.should be_valid
      end

      it "rejects a bad or missing appt date" do
        @post.should_not be_valid
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

      it "rejects a bad or missing completed date" do
        @post.should_not be_valid
      end
    end
  end
end
