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

  def add_invoice code='unpaid'
    @seller = FactoryGirl.create(:pixi_user, first_name: 'Kim', last_name: 'Harris', email: 'kimmy@pixitest.com')
    @invoice = @seller.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @user.id, status: code)
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

    it 'shows content' do
      expect(page).to have_link('Sent', href: sent_posts_path)
      expect(page).to have_link('Received', href: posts_path)
      expect(page).not_to have_link('Mark All Read', href: mark_posts_path)
      expect(page).to have_content 'No messages found.'
      expect(page).not_to have_button('Pay')
      expect(page).not_to have_button('Reply')
    end
  end

  describe 'Received messages' do
    before :each do
      add_post
      visit posts_path 
      # click_on 'notice-btn'
    end

    it 'shows content' do
      expect(page).to have_selector('title', :text => full_title('Messages'))
      expect(page).to have_content @post.user.name
      expect(page).to have_link('Sent', href: sent_posts_path)
      expect(page).to have_link('Received', href: posts_path)
      expect(page).to have_link('Mark All Read', href: mark_posts_path)
      expect(page).not_to have_button('Pay')
    end

    it "replies to a message", js: true do
      send_reply
    end
     
    it "does not reply to a message", js: true do
      expect{
	  fill_in 'reply_content', with: nil
          click_reply
      }.not_to change(Post,:count).by(1)

      expect(page).to have_content "Content can't be blank"
    end

    it "marks all posts read", js: true do
      click_on 'Mark All Read'
      expect(page).to have_css('li.active a') 
    end
     
    describe 'pay invoice' do
      before :each do
        add_post
        add_invoice
	visit posts_path
      end

      it { is_expected.to have_button('Pay') }

      it "opens pay invoice page" do
        click_on 'Pay'
        expect(page).to have_content 'Amount Due'
      end
    end
     
    describe 'removed invoice' do
      before :each do
        add_post
        add_invoice
        @listing.status = 'removed'
	@listing.save; sleep 2
	visit posts_path
      end

      it "does not show pay button for removed pixi" do
	expect(Invoice.where(status: 'removed').count).to eq 1
        expect(page).not_to have_button('Pay')
      end
    end
     
    describe 'paid invoice' do
      before :each do
        add_post
        add_invoice 'paid'
	visit posts_path
      end

      it "does not show pay button for paid pixi" do
	expect(Invoice.where(status: 'paid').count).to eq 1
        expect(page).not_to have_button('Pay')
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
    
    it 'shows content' do
      expect(page).to have_link('Mark All Read', href: mark_posts_path)
      expect(page).to have_content @post.user.name
      expect(page).to have_content @post.listing.title
      expect(page).to have_content @post.content
      expect(page).to have_button('Reply')
      expect(page).to have_button('Pay')
    end

    it "replies to a message" do
      send_reply
    end
     
    it "does not reply to a message" do
      expect{
	  fill_in 'reply_content', with: nil
          click_reply
      }.not_to change(Post,:count).by(1)

      expect(page).to have_content "Content can't be blank"
    end

    it "pays an invoice" do
      click_on 'Pay'
      expect(page).to have_content 'Total Due'
    end
  end
     
  describe 'No sent messages' do
    before :each do 
      visit posts_path 
    end

    it 'shows no sent messages', js: true do
      click_on 'Sent'
      expect(page).not_to have_link('Mark All Read', href: mark_posts_path) 
      expect(page).to have_content 'No messages found' 
    end
  end
     
  describe 'sent messages' do
    before :each do 
      @reply_post = FactoryGirl.create :post, user: @user, recipient: @sender, listing: @listing, pixi_id: @listing.pixi_id
      visit posts_path 
    end

    it 'shows sent messages', js: true do
      click_on 'Sent'
      expect(page).not_to have_link('Mark All Read', href: mark_posts_path) 
      expect(page).to have_content @reply_post.recipient.name 
      expect(page).to have_content @reply_post.listing.title 
      expect(page).to have_content @reply_post.content 
    end
  end
end
