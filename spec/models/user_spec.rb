require 'spec_helper'

describe User do
  before(:all) do
    @user = create(:contact_user, status: 'active')
  end

  subject { @user }

  describe "user methods", base: true do
    it_behaves_like "an user"
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    it { should respond_to(:birth_date) }
    it { should respond_to(:remember_me) }
    it { should respond_to(:gender) }
    it { should respond_to(:provider) }
    it { should respond_to(:uid) }
    it { should respond_to(:fb_user) }
    it { should respond_to(:pictures) }
    it { should respond_to(:status) }
    it { should respond_to(:acct_token) }
    it { should respond_to(:user_type_code) }
    it { should respond_to(:business_name) }
    it { should respond_to(:ref_id) }
    it { should respond_to(:url) }

    it { should respond_to(:interests) }
    it { should respond_to(:contacts) }
    it { should respond_to(:user_interests) }
    it { should respond_to(:transactions) }
    it { should respond_to(:user_pixi_points) }
    it { should respond_to(:listings) } 
    it { should respond_to(:temp_listings) } 
    it { should respond_to(:active_listings) } 
    it { should respond_to(:pixi_posted_listings) } 
    it { should respond_to(:posts) } 
    it { should respond_to(:incoming_posts) } 
    it { should respond_to(:invoices) } 
    it { should respond_to(:received_invoices) } 
    it { should respond_to(:unpaid_received_invoices) } 
    it { should respond_to(:unpaid_invoices) } 
    it { should respond_to(:paid_invoices) } 
    it { should respond_to(:bank_accounts) } 
    it { should respond_to(:card_accounts) } 
    it { should respond_to(:comments) }
    it { should respond_to(:ratings) }
    it { should respond_to(:inquiries) }
    it { should respond_to(:seller_ratings) }
    it { should respond_to(:pixi_posts) }
    it { should respond_to(:active_pixi_posts) }
    it { should respond_to(:pixan_pixi_posts) }

    it { should have_many(:received_conversations).class_name('Conversation').with_foreign_key('recipient_id') }
    it { should have_many(:sent_conversations).class_name('Conversation').with_foreign_key('user_id') }
    it { should have_many(:active_listings).class_name('Listing').with_foreign_key('seller_id')
      .conditions("status='active' AND end_date >= curdate()") }
    it { should have_many(:pixi_posted_listings).class_name('Listing').with_foreign_key('seller_id')
      .conditions("status='active' AND end_date >= curdate() AND pixan_id IS NOT NULL") }
    it { should have_many(:purchased_listings).class_name('Listing').with_foreign_key('buyer_id').conditions(:status=>"sold") }
    it { should respond_to(:pixan_pixi_posts) }
    it { should have_many(:pixan_pixi_posts).class_name('PixiPost').with_foreign_key('pixan_id') }
    it { should respond_to(:pixi_likes) }
    it { should have_many(:pixi_likes) }
    it { should respond_to(:saved_listings) }
    it { should have_many(:saved_listings) }
    it { should respond_to(:pixi_wants) }
    it { should have_many(:pixi_wants) }
    it { should respond_to(:pixi_asks) }
    it { should have_many(:pixi_asks) }
    it { should respond_to(:preferences) }
    it { should have_many(:preferences).dependent(:destroy) }
    it { should accept_nested_attributes_for(:preferences).allow_destroy(true) }
    it { should belong_to(:user_type).with_foreign_key('user_type_code') }

    it { should respond_to(:unpaid_invoice_count) } 
    it { should respond_to(:has_unpaid_invoices?) } 
    it { should respond_to(:has_address?) } 
    it { should respond_to(:has_pixis?) } 
    it { should respond_to(:has_bank_account?) } 
    it { should respond_to(:has_card_account?) } 

    it { should validate_presence_of(:gender) }
    it { should validate_presence_of(:birth_date) }
    it { should validate_presence_of(:url).on(:create) }
    it { should validate_uniqueness_of(:url) }
    it { should validate_length_of(:url).is_at_least(2) }
    it { should allow_value('Tom').for(:url) }
    it { should_not allow_value("a").for(:url) }

    it { should have_many(:favorite_sellers) }
    it { should have_many(:sellers) }
    it { should have_many(:inverse_favorite_sellers).class_name('FavoriteSeller').with_foreign_key('seller_id') }
    it { should have_many(:followers) }
  end

  describe 'name' do
    before :each, run: true do
      @usr = build(:user, first_name: "John", last_name: "Doe", email: "jdoe@test.com")
    end

    it "returns a user's full name as a string", run: true do
      @usr.name.should == "John Doe"
    end

    it "does not return a user's invalid full name as a string", run: true do
      @usr.name.should_not == "John Smith"
    end

    it "does not return a user's invalid full name when a business" do
      @usr = build :pixi_user, first_name: 'John', last_name: 'Smith', birth_date: nil, gender: nil, user_type_code: 'BUS', business_name: 'Company A'
      @usr.name.should_not == "John Smith"
    end

    it "returns a business name when a business" do
      @usr = build :pixi_user, first_name: 'John', last_name: 'Smith', birth_date: nil, gender: nil, user_type_code: 'BUS', business_name: 'Company A'
      @usr.name.should == "Company A"
    end

    it "returns a user's abbr name as a string", run: true do
      @usr.abbr_name.should == "John D"
      @usr.abbr_name.should_not == "John Doe"
    end
  end

  describe 'contacts' do
    before(:each) do
      @sr = @user.contacts.build attributes_for(:contact)
    end

    it "has many contacts" do 
      @user.contacts.should include(@sr)
    end

    it "should destroy associated contacts" do
      @user.destroy
      [@sr].each do |s|
         Contact.find_by_id(s.id).should be_nil
       end
    end 
  end  

  describe 'temp_listings' do
    before(:each) do
      @sr = @user.temp_listings.create attributes_for(:temp_listing)
    end

    it "has many temp_listings" do 
      @user.temp_listings.should include(@sr)
    end

    it "should destroy associated temp_listings" do
      @user.destroy
      [@sr].each do |s|
         TempListing.find_by_id(s.id).should be_nil
       end
    end 
  end  

  describe 'with_picture' do
    let(:user) { build :user }
    let(:pixi_user) { build :pixi_user }

    it "adds a picture" do
      user.with_picture.pictures.size.should == 1
    end

    it "does not add a picture" do
      pixi_user.with_picture.pictures.size.should == 1
    end
  end  

  describe 'pictures' do
    before(:each) do
      @sr = @user.pictures.create attributes_for(:picture)
    end

    it "has many pictures" do 
      @user.pictures.should include(@sr)
    end

    it "destroys associated pictures" do
      @user.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
    end 
  end  

  describe 'home_zip' do
    let(:user) { build :user }
    it { expect(@user.home_zip).not_to be_nil }
    it { expect(user.home_zip).to be_nil }
    it { expect(@user.home_zip=('94108')).to eq('94108') }
    it { expect(user.home_zip=(nil)).to be_nil }
  end

  describe "must have pictures" do
    let(:user) { build :user }

    it "does not save w/o at least one picture" do
      picture = user.pictures.build
      user.save
      user.should_not be_valid
    end

    it "saves with at least one picture" do
      picture = user.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      user.home_zip = '94108'
      user.save
      user.should be_valid
    end
  end

  describe "must have zip" do
    let(:user) { build :user }
    before :each do
      picture = user.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
    end

    it "does not save w/o zip" do
      user.save
      user.should_not be_valid
    end

    it "does not save with invalid zip" do
      user.home_zip = '99999'
      user.save
      user.should_not be_valid
    end

    it "does not save zip with invalid length" do
      user.home_zip = '12'
      user.save
      user.should_not be_valid
    end

    it "saves with zip" do
      user.home_zip = '94108'
      user.save
      user.should be_valid
    end
  end

  describe 'pixis' do
    it "returns pixis" do
      @listing = create(:listing, seller_id: @user.id)
      @user.listings.create attributes_for(:listing, status: 'active')
      @user.pixis.should_not be_empty
      @user.has_pixis?.should be_true
    end

    it "does not return pixis" do
      usr = create :contact_user
      usr.pixis.should be_empty
      @user.has_pixis?.should_not be_true
    end
  end

  describe 'sold pixis' do
    it "returns pixis" do
      @listing = create(:listing, seller_id: @user.id, status: 'sold')
      @user.sold_pixis.should_not be_empty
    end

    it "does not return pixis" do
      usr = create :contact_user
      usr.sold_pixis.should be_empty
    end
  end

  describe 'new pixis' do
    it "returns new pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id)
      @user.new_pixis.should_not be_empty
    end

    it "returns denied pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id, status: 'denied')
      @user.new_pixis.should_not be_empty
    end

    it "does not return new pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id, status: 'pending')
      @user.new_pixis.should be_empty
    end
  end

  describe 'pending pixis' do
    it "returns pending pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id, status: 'pending')
      @user.pending_pixis.should_not be_empty
    end

    it "does not return denied pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id, status: 'denied')
      @user.pending_pixis.should be_empty
    end

    it "does not return pending pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id)
      @user.pending_pixis.should be_empty
    end
  end

  describe 'bank_account' do
    it "has account" do
      @user.bank_accounts.create attributes_for(:bank_account, status: 'active')
      @user.has_bank_account?.should be_true
    end

    it "does not have account" do
      @user.has_bank_account?.should_not be_true
    end
  end

  describe 'card_account' do
    it "has account" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active')
      @user.has_card_account?.should be_true
    end

    it "does not have account" do
      @user.has_card_account?.should_not be_true
    end

    it "has valid card" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active')
      @user.get_valid_card.should be_true
    end

    it "has valid card & expired card" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active')
      @user.card_accounts.create attributes_for(:card_account, status: 'active', expiration_year: Date.today.year, 
        expiration_month: Date.today.month-1)
      @user.get_valid_card.should be_true
    end

    it "has invalid card - old year" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active', expiration_year: Date.today.year-1)
      @user.get_valid_card.should_not be_true
    end

    it "has invalid card - same year, old month" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active', expiration_year: Date.today.year, 
        expiration_month: Date.today.month-1)
      @user.get_valid_card.should_not be_true
    end

    it "does not have valid card" do
      @user.get_valid_card.should_not be_true
    end
  end

  describe 'facebook' do
    let(:user) { build :user }
    let(:auth) { OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
               provider: 'facebook', uid: "fb-12345", 
	       info: { name: "Bob Smith", image: "http://graph.facebook.com/708798320/picture?type=square" }, 
	       extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',
	                email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } } }) }

    it 'should return a user' do
      User.find_for_facebook_oauth(auth).email.should == 'bob.smith@test.com'
    end

    it 'should return a picture' do
      User.picture_from_url(user, auth).should_not be_nil
    end
  end

  describe 'password' do
    let(:user) { build :user }

    it 'should valid password' do
      user.password_required?.should be_true  
    end

    it 'should confirm password' do
      user.confirmation_required?.should be_true  
    end

    it 'should not valid password' do
      user.provider = 'facebook'
      user.password_required?.should_not be_true  
    end

    it 'should not confirm password' do
      user.provider = 'facebook'
      user.confirmation_required?.should_not be_true  
    end
  end

  describe "pic_with_name" do 
    let(:user) { build :user }

    it "should not be true" do
      user.pic_with_name.should_not be_true
    end

    it "should be true" do
      @user.pic_with_name.should be_true
    end
  end

  describe "status" do 
    it { @user.active?.should be_true }

    it 'should not be active' do
      user = build :user, status: 'inactive'
      user.active?.should_not be_true
    end

    it 'should be inactive' do
      @user.deactivate.status.should_not == 'active'
    end

    it 'should be inactive' do
      @user.deactivate.status.should == 'inactive'
    end
  end

  describe 'has_address?' do
    it 'should return true' do
      @user.has_address?.should be_true
    end

    it 'should not return true' do
      user = build :user
      user.has_address?.should_not be_true
    end
  end

  describe 'new_user?' do
    it 'should return true' do
      @user.sign_in_count = 1
      @user.new_user?.should be_true
    end

    it 'should not return true' do
      user = build :user
      user.new_user?.should_not be_true
    end
  end

  describe 'convert time' do
    it 'should return a date' do
      User.convert_date("01/13/1989").should == "13/01/1989".to_date
    end

    it 'should not return a date' do
      User.convert_date(nil).should_not == "13/01/1989".to_date
    end
  end

  describe 'birth_dt' do
    it 'should return a date' do
      @user.birth_dt.should == "04/23/1967"
    end

    it 'should not return a date' do
      @user.birth_date = nil
      @user.birth_dt.should_not == "04/23/1967"
    end
  end

  describe 'nice_date' do
    it 'returns a nice date' do
      @user.nice_date(@user.created_at).should == @user.created_at.utc.getlocal.strftime('%m/%d/%Y %l:%M %p')
    end

    it 'does not return a nice date' do
      user = build :pixi_user
      user.nice_date(user.created_at).should be_nil
    end
  end

  describe 'is_pixter?' do
    it { @user.is_pixter?.should be_false }

    it 'is true' do
      @pixter = create(:pixi_user, user_type_code: 'PT') 
      expect(@pixter.is_pixter?).to be_true
    end
  end

  describe 'is_member?' do
    it { @user.is_member?.should be_true }

    it 'is false' do
      @pixter = create(:pixi_user, user_type_code: 'PT') 
      expect(@pixter.is_member?).to be_false
    end
  end

  describe 'is_business?' do
    it { @user.is_business?.should_not be_true }

    it 'is a business' do
      @company = FactoryGirl.build(:pixi_user, user_type_code: 'BUS') 
      expect(@company.is_business?).to be_true
    end
  end

  describe 'is_support?' do
    it { @user.is_support?.should be_false }

    it 'is true' do
      @support = create(:pixi_user, user_type_code: 'SP') 
      expect(@support.is_support?).to be_true
    end
  end

  describe 'is_admin?' do
    it { @user.is_admin?.should be_false }

    it 'is true' do
      @admin = create(:pixi_user, user_type_code: 'AD') 
      expect(@admin.is_admin?).to be_true
    end
  end

  describe "listing associations" do
    before do
      @buyer = create(:pixi_user) 
      @pixter = create(:pixi_user, user_type_code: 'PT') 
      @listing = create(:listing, seller_id: @user.id)
      @pp_listing = create(:listing, seller_id: @user.id, pixan_id: @pixter.id)
      @sold_listing = create(:listing, seller_id: @buyer.id, status: 'sold')
    end

    it 'accesses listings' do 
      expect(@user.active_listings).to include(@listing) 
      expect(@buyer.active_listings).not_to include(@sold_listing)
      expect(@user.pixi_posted_listings).to include(@pp_listing)
      expect(@user.pixi_posted_listings).not_to include(@listing)
    end
  end

  describe "invoice associations" do
    before do
      @buyer = create(:pixi_user) 
      @listing = create(:listing, seller_id: @user.id)
    end

    it 'should not have unpaid invoices' do
      @user.unpaid_invoices.should be_empty
    end

    it 'should have only unpaid invoices' do
      @invoice = @user.invoices.create attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id, status: 'unpaid')
      @user.unpaid_invoices.should_not be_empty
      @buyer.paid_invoices.should be_empty
      @buyer.has_unpaid_invoices?.should be_true 
    end

    it 'should have paid invoices' do
      @account = @user.bank_accounts.create attributes_for :bank_account
      @invoice = @user.invoices.create attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id, 
        bank_account_id: @account.id, status: 'paid')
      @user.paid_invoices.should_not be_empty
      @user.unpaid_invoices.should be_empty
      @buyer.has_unpaid_invoices?.should_not be_true 
    end
  end

  describe "get by type" do
    it "includes pixans" do
      @user.user_type_code = 'PX'
      @user.save
      expect(User.get_by_type(['PX', 'PT'])).not_to be_empty
    end

    it "includes all" do
      expect(User.get_by_type(nil)).not_to be_empty
    end

    it "does not include pixans" do
      expect(User.get_by_type(['PX', 'PT'])).not_to include(@user)
    end
  end

  describe 'type_descr' do
    it "shows description" do
      create :user_type
      @user.user_type_code = 'PX'
      expect(@user.type_descr).to eq 'Pixan'
    end

    it "does not show description" do
      expect(@user.type_descr).to be_nil
    end
  end

  describe "find_user" do
    it 'finds a user' do
      expect(User.find_user(@user.id)).not_to be_nil
    end

    it 'does not find user' do
      expect(User.find_user(0)).to be_nil
    end
  end

  describe 'async_send_notifications' do

    def send_mailer usr
      @mailer = mock(UserMailer)
      UserMailer.stub!(:delay).and_return(@mailer)
      @mailer.stub(:welcome_email).with(usr).and_return(@mailer)
    end

    it 'adds dr pixi points' do
      @user = create :pixi_user 
      expect(@user.user_pixi_points.count).not_to eq(0)
      @user.user_pixi_points.find_by_code('dr').code.should == 'dr'
      @user.user_pixi_points.find_by_code('fr').should be_nil
    end

    it 'adds fr pixi points' do
      @pixi_user = create :pixi_user, uid: '11111' 
      @pixi_user.user_pixi_points.find_by_code('fr').code.should == 'fr'
      @pixi_user.user_pixi_points.find_by_code('dr').should be_nil
    end

    it 'delivers the welcome message' do
      @pixi_user = create :pixi_user, uid: '11111' 
      send_mailer @user if @pixi_user.fb_user?
    end
  end

  describe "post associations" do
    let(:listing) { create :listing, seller_id: @user.id }
    let(:newer_listing) { create :listing, seller_id: @user.id }
    let(:recipient) { create :pixi_user, first_name: 'Wilson' }
    let(:conversation) { create :conversation, user: @user, recipient: recipient, listing: listing, pixi_id: listing.pixi_id }
    let!(:older_post) do 
      create(:post, user: @user, recipient: recipient, listing: listing, pixi_id: listing.pixi_id, created_at: 1.day.ago, conversation_id: conversation.id, conversation: conversation)
    end

    let!(:newer_post) do
      create(:post, user: @user, recipient: recipient, listing: newer_listing, pixi_id: newer_listing.pixi_id, created_at: 1.hour.ago, conversation_id: conversation.id, conversation: conversation)
    end

    it "should have the right posts in the right order" do
      @user.posts.should == [newer_post, older_post]
    end

    it "should destroy associated posts" do
      posts = @user.posts.dup
      @user.destroy
      posts.should_not be_empty

      posts.each do |post|
        Post.find_by_id(post.id).should be_nil
      end
    end
  end

  describe "exporting as CSV" do

    it "exports data as CSV file" do
      csv_string = @user.as_csv
      csv_string.keys.should =~ ["Name", "Email", "Home Zip", "Birth Date", "Enrolled", "Last Login", "Gender", "Age"] 
      csv_string.values.should =~ [@user.name, @user.email, @user.home_zip, @user.birth_dt, @user.nice_date(@user.created_at), 
        @user.nice_date(@user.last_sign_in_at), @user.gender, @user.age] 
    end

    it "does not export any user data" do
      usr = build :user
      csv = usr.as_csv
      csv.values.should include(nil)
    end
  end

  describe "get conversations" do
    before(:each) do
      @user = create :pixi_user
      @recipient = create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tom.davis@pixitest.com'
      @buyer = create :pixi_user, first_name: 'Jack', last_name: 'Smith', email: 'jack.smith99@pixitest.com'
      @listing = create :listing, seller_id: @user.id, title: 'Big Guitar'
      @listing2 = create :listing, seller_id: @recipient.id, title: 'Small Guitar'
      @conversation = @listing.conversations.create attributes_for :conversation, user_id: @recipient.id, recipient_id: @user.id
      @conversation2 = @listing2.conversations.create attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id 
      @post = @conversation.posts.create attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
      @post2 = @conversation2.posts.create attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, pixi_id: @listing2.pixi_id

    end

    it "gets all conversations for user" do
      expect(@user.get_conversations.count).to eql(2)
    end

    it "gets right sent conversations for user" do
      expect(@user.get_conversations).to include(@conversation2)
    end

    it "gets right received conversations for user" do
      expect(@user.get_conversations).to include(@conversation)
    end

    it "gets no conversations when there are none" do
      Conversation.destroy_all
      expect(@user.get_conversations).to eql([])
    end
  end

  describe "is_admin?" do
    it "returns true for admin" do
      @user = create :admin
      @user.user_type_code = 'AD'
      @user.save!
      expect(@user.is_admin?).to be_true
    end

    it "returns false for non-admin" do
      @user = create :pixi_user
      expect(@user.is_admin?).to be_false
    end
  end

  describe "is_business?" do
    it "returns true for business" do
      @user = create :pixi_user, birth_date: nil, gender: nil, user_type_code: 'BUS', business_name: 'Company A'
      expect(@user.is_business?).to be_true
    end

    it "returns false for non-business" do
      @user = create :pixi_user
      expect(@user.is_business?).to be_false
    end
  end

  describe "url" do
    it 'generates url' do
      @user.user_url = @user.name
      expect(@user.url).to eq @user.name.gsub!(/\s+/, "") + '1'
    end

    it 'generates unique url' do
      @user.user_url = @user.name
      @user.save!
      user2 = create :pixi_user, first_name: @user.first_name, last_name: @user.last_name
      expect(user2.url).not_to eq @user.url
    end

    it 'generates url for business' do
      user = build :contact_user, user_type_code: 'BUS', business_name: 'Toy Shack'
      user.save!
      expect(user.url).to eq user.business_name.gsub!(/\s+/, "").downcase
    end
  end

  describe 'code_type' do
    it "shows code" do
      @user.user_type_code = 'px'
      expect(@user.code_type).to eq 'PX'
    end

    it "shows default code" do
      usr = build :user
      expect(usr.code_type).not_to be_nil
    end
  end

  describe 'guest' do
    before :each, run: true do
      @test_user = build :pixi_user, guest: true
    end

    it { expect(@user.guest?).not_to be_true }
    it 'returns true', run: true do
      expect(@test_user.guest?).to be_true
    end
  end

  describe 'new_guest' do
    it { expect(User.new_guest.status).to eq 'inactive' }
    it { expect(User.new_guest.guest?).to be_true }
    it 'saves guest user' do
      user = User.new_guest
      expect(User.where(status: 'inactive').count).to eq 1
    end
  end

  describe 'move_to' do
    before :each, run: true do
      @usr = create :pixi_user
    end
    it 'moves user pixipost content', run: true do
      @pixi_post_zip = create(:pixi_post_zip)
      attr = {"preferred_date"=>"04/05/2015", "preferred_time"=>"13:00:00", "alt_date"=>"", "alt_time"=>"12:00:00", 
      "quantity"=>"2", "value"=>"200.0", "description"=>"xbox 360 box.", "address"=>"123 Elm", "address2"=>"", "city"=>"LA", "state"=>"CA", 
      "zip"=>"90201", "home_phone"=>"4155551212", "mobile_phone"=>"", "user_id"=>""}
      @post = PixiPost.add_post(attr, User.new)
      @post.save!
      @post.user.move_to(@usr)
      expect(@usr.pixi_posts.size).to eq 1
      expect(@usr.contacts.size).to eq 1
      expect(@post.user.pixi_posts.size).to eq 0
    end
    it 'moves user temp listings', run: true do
      @listing = TempListing.add_listing(set_temp_attr(''), TempListing.new)
      @listing.save!
      @listing.user.move_to(@usr)
      expect(@usr.temp_listings.size).to eq 1
      expect(@listing.user.temp_listings.size).to eq 0
    end
    it 'does not move user content' do
      usr = create :pixi_user
      usr.move_to(nil)
      expect(usr.contacts.size).to eq 1
    end
  end

  describe "user status" do
    it { User.active.should_not be_nil }
    it 'have no active users' do
      @user.update_attribute(:status, 'inactive')
      expect(User.active).to be_blank
    end
  end

  describe 'set_flds' do
    let(:user) { build :pixi_user }
    it { expect{ user.save }.to change{ user.status } }
    it { expect{ user.save }.to change{ user.user_type_code } }
    it 'sets url' do
      user.save!
      expect( user.url ).not_to be_blank
    end
    it 'does not set user_type' do
      user.user_type_code = 'AD'
      expect{ user.save }.not_to change { user.user_type_code } 
    end
    it 'does not set status for guest' do
      user.guest = true  
      expect{ user.save }.not_to change{ user.status } 
    end
  end

  describe 'primary_address', address: true do
    it { expect(@user.primary_address).not_to be_blank }
    it 'has no address' do
      user = build :pixi_user
      expect(user.primary_address).to be_blank
    end
  end

  describe 'site_name' do
    it { expect(@user.site_name).not_to be_nil }
    it 'returns nil' do
      @user.home_zip = '00000'
      expect(@user.site_name).to be_nil
    end
  end

  describe 'get_sellers' do
    before :each, run: true do
      @listing = create :listing, seller_id: @user.id
      @site = create :site, org_type: 'city', name: 'SF'
      @site.contacts.create(FactoryGirl.attributes_for(:contact, address: '101 California', city: 'SF', state: 'CA', zip: '94111'))
      @listing.update_attribute(:site_id, @site.id)
    end
    it { expect(User.get_sellers(0, 1)).to be_empty }
    it 'has no business users', run: true do
      expect(User.get_sellers(@listing.category_id, @listing.site_id)).to be_empty
    end
    it 'has a business user in different site', run: true do
      @user.update_attribute(:user_type_code, 'BUS')
      expect(User.get_sellers(@listing.category_id, 100)).to be_empty
    end
    it 'has a business user in different category', run: true do
      @user.update_attribute(:user_type_code, 'BUS')
      expect(User.get_sellers(100, @listing.site_id)).to be_empty
    end
    it 'has a business user w insufficient pixis', run: true do
      @user.update_attribute(:user_type_code, 'BUS')
      expect(User.get_sellers(@listing.category_id, @listing.site_id)).to be_empty
    end
    it 'has a business user w sufficient pixis', run: true do
      @user.update_attribute(:user_type_code, 'BUS')
      listing = create :listing, seller_id: @user.id, title: 'Leather Coat', site_id: @site.id
      expect(User.get_sellers(@listing.category_id, @listing.site_id)).not_to be_empty
    end
  end

  describe "is_followed?" do
    before :each do
      @user2 = create :contact_user
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "returns users that are following the seller" do
      expect(@seller.is_followed?(@user)).to be_true
    end

    it "does not return users that aren't following the seller" do
      expect(@seller.is_followed?(@user2)).to be_false
    end
  end

  describe "is_following?" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @seller2 = create(:contact_user, user_type_code: 'BUS', business_name: 'Another Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "returns users that are following the seller" do
      expect(@user.is_following?(@seller)).to be_true
    end

    it "does not return users that aren't following the seller" do
      expect(@user.is_following?(@seller2)).to be_false
    end
  end

  describe "get_by_ftype" do
    it "calls get_by_seller if ftype='seller'" do
      User.should_receive :get_by_seller
      User.get_by_ftype('seller', nil, 'active')
    end

    it "calls get_by_user otherwise" do
      User.should_receive :get_by_user
      User.get_by_ftype('buyer', nil, 'active')
    end
  end

  describe "get_by_seller" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "'active' status returns users following the seller_id provided" do
      expect(UserProcessor.new(nil).get_by_seller(@favorite_seller.seller_id, 'active')).to include @user
    end

    it "'removed' status returns users that unfollowed the seller_id provided" do
      @favorite_seller.update_attribute(:status, 'removed')
      expect(UserProcessor.new(nil).get_by_seller(@favorite_seller.seller_id, 'removed')).to include @user
    end

    it "returns nil if there are no users following the seller_id provided" do
      expect(UserProcessor.new(nil).get_by_seller(@favorite_seller.seller_id - 1, 'active')).to be_empty
    end
    
    it "returns all followers if seller_id is blank" do
      expect(UserProcessor.new(nil).get_by_seller(nil, 'active')).to include @user
    end
  end

  describe "get_by_user" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "'active' status returns sellers followed by the user_id provided" do
      expect(UserProcessor.new(nil).get_by_user(@favorite_seller.user_id, 'active')).to include @seller
    end

    it "'removed' status returns sellers that were unfollowed by the user_id provided" do
      @favorite_seller.update_attribute(:status, 'removed')
      expect(UserProcessor.new(nil).get_by_user(@favorite_seller.user_id, 'removed')).to include @seller
    end

    it "returns nil if there are no sellers followed by the seller_id provided" do
      expect(UserProcessor.new(nil).get_by_user(@favorite_seller.user_id - 1, 'active')).to be_empty
    end
    
    it "returns all sellers if seller_id is blank" do
      expect(UserProcessor.new(nil).get_by_user(nil, 'active')).to include @seller
    end
  end

  describe "date_followed" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "returns date followed if available" do
      expect(@user.date_followed(@seller).to_s).to eq @favorite_seller.updated_at.to_s
    end

    it "returns nil otherwise" do
      expect(@seller.date_followed(@user)).to be_nil
    end
  end

  describe "favorite_seller_id" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "returns id of FavoriteSeller object if available" do
      expect(@user.favorite_seller_id(@seller)).to eq @favorite_seller.id
    end

    it "returns nil otherwise" do
      expect(@seller.favorite_seller_id(@user)).to be_nil
    end
  end
end
