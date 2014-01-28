require 'spec_helper'

feature "Messages" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
    @sender = FactoryGirl.create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tdavis@pixitest.com'
    @listing = FactoryGirl.create :listing, seller_id: @user.id
  end

  def click_reply
    click_on 'Reply'
    sleep 3
  end

  def add_invoice
    @seller = FactoryGirl.create(:pixi_user, first_name: 'Kim', last_name: 'Harris', email: 'kimmy@pixitest.com')
    @invoice = @seller.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @user.id)
  end
   
  def add_post
    @post = FactoryGirl.create :post, user: @sender, recipient: @user, listing: @listing, pixi_id: @listing.pixi_id
  end

  def send_reply
    expect{
      fill_in 'reply_content', with: "I'm interested in this pixi. Please contact me." 
      click_reply
    }.to change(Post,:count).by(1)
  end

  describe 'Received messages w no messages' do
    before :each do
      visit listings_path 
      click_on 'notice-btn'
    end

    it { should have_link('Sent', href: sent_posts_path) }
    it { should have_link('Received', href: posts_path) }
    it { should_not have_link('Mark All Read', href: mark_posts_path) }
    it { should have_content 'No messages found.' }
    it { should_not have_button('Pay') }
    it { should_not have_button('Reply') }
  end

  describe 'Received messages' do
    before :each do
      add_post
      visit listings_path 
      click_on 'notice-btn'
    end

    it { should have_selector('title', :text => full_title('Posts')) }
    it { should have_content @post.user.name }
    it { should have_link('Sent', href: sent_posts_path) }
    it { should have_link('Received', href: posts_path) }
    it { should have_link('Mark All Read', href: mark_posts_path) }
    it { should_not have_button('Pay') }

    it "replies to a message", js: true do
      send_reply
    end
     
    it "does not reply to a message", js: true do
      expect{
	  fill_in 'reply_content', with: nil
          click_reply
      }.not_to change(Post,:count).by(1)

      page.should have_content "Content can't be blank"
    end

    it "marks all posts read", js: true do
      click_on 'Mark All Read'
      page.should have_css('li.active a') 
    end
     
    describe 'pay invoice' do
      before :each do
        add_post
        add_invoice
	visit posts_path
      end

      it { should have_button('Pay') }

      it "opens pay invoice page" do
        click_on 'Pay'
        page.should have_selector('title', text: 'Pay Invoice')
        page.should have_content 'Total Due'
      end
    end
  end
     
  describe 'Received messages - ajax', js: true do
    before :each do
      add_post
      add_invoice
      visit posts_path 
      click_on 'Sent'
      click_on 'Received'
    end
    
    it { should have_link('Mark All Read', href: mark_posts_path) }
    it { should have_content @post.user.name }
    it { should have_content @post.listing.title }
    it { should have_content @post.content }
    it { should have_button('Reply') }
    it { should have_button('Pay') }

    it "replies to a message" do
      send_reply
    end
     
    it "does not reply to a message" do
      expect{
	  fill_in 'reply_content', with: nil
          click_reply
      }.not_to change(Post,:count).by(1)

      page.should have_content "Content can't be blank"
    end

    it "pays an invoice" do
      click_on 'Pay'
      page.should have_selector('title', text: 'Pay Invoice')
      page.should have_content 'Total Due'
    end
  end
     
  describe 'No sent messages' do
    before :each do 
      visit posts_path 
    end

    it 'shows no sent messages', js: true do
      click_on 'Sent'
      page.should_not have_link('Mark All Read', href: mark_posts_path) 
      page.should have_content 'No messages found' 
    end
  end
     
  describe 'sent messages' do
    before :each do 
      @reply_post = FactoryGirl.create :post, user: @user, recipient: @sender, listing: @listing, pixi_id: @listing.pixi_id
      visit posts_path 
    end

    it 'shows sent messages', js: true do
      click_on 'Sent'
      page.should_not have_link('Mark All Read', href: mark_posts_path) 
      page.should have_content @reply_post.recipient.name 
      page.should have_content @reply_post.listing.title 
      page.should have_content @reply_post.content 
    end
  end
end
