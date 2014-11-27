require 'spec_helper'
require 'will_paginate'

feature "Conversations" do
  subject { page }

  before(:each) do
    @user = FactoryGirl.create :pixi_user
    login_as(@user, :scope => :user, :run_callbacks => false)
    @sender = FactoryGirl.create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tdavis@pixitest.com'
    @listing = FactoryGirl.create :listing, seller_id: @user.id
  end

  def add_invoice
    @seller = FactoryGirl.create(:pixi_user, first_name: 'Kim', last_name: 'Harris', email: 'kimmy@pixitest.com')
    @invoice = @seller.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @user.id)
  end

  def paid_invoice
    @seller = FactoryGirl.create(:pixi_user, first_name: 'Kim', last_name: 'Harris', email: 'kimmy@pixitest.com')
    @invoice = @seller.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @user.id, status: 'paid')
  end
   
  def add_post conv
    @post_reply = conv.posts.create FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @sender.id, pixi_id: @listing.pixi_id
  end

  def add_conversation
    @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @sender.id, recipient_id: @user.id
    @post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @sender.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
  end

  def add_system_conversation
    @support = FactoryGirl.create(:pixi_user, first_name: 'Pixiboard', last_name: 'Support', email: 'support@pixiboard.com')
    @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @support.id, recipient_id: @user.id
    @post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @support.id, recipient_id: @user.id, pixi_id: @listing.pixi_id, 
      msg_type: 'system'
  end

  def send_reply
    expect{
      fill_in 'reply_content', with: "I'm interested in this pixi. Please contact me." 
      click_send
    }.to change(Post,:count).by(1)
  end

  def click_send
    click_on 'Send'
    sleep 3
  end

  def click_remove_ok
    page.driver.browser.switch_to.alert.accept
  end

  describe 'Received conversations w no conversations' do
    before :each do
      visit listings_path 
      click_on 'notice-btn'
    end

    it 'shows content' do
      @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @sender.id, recipient_id: @user.id
      page.should have_link('Sent', href: conversations_path(status: 'sent'))
      page.should have_link('Received', href: conversations_path(status: 'received'))
      page.should_not have_link('Mark All Read', href: mark_posts_path)
      page.should have_content 'No conversations found.'
      page.should_not have_selector('#conv-trash-btn') 
      page.should_not have_selector('#conv-pay-btn') 
      page.should_not have_button('Reply')
    end
  end

  describe 'Received conversations' do
    before :each do
      add_conversation
      visit listings_path 
      click_on 'notice-btn'
    end

    it 'shows content' do
      page.should have_selector('title', :text => full_title('Messages'))
      page.should have_content @conversation.user.name
      page.should have_link('Sent', href: conversations_path(status: 'sent'))
      page.should have_link('Received', href: conversations_path(status: 'received'))
      page.should have_link('Mark All Read', href: mark_posts_path)
      page.should have_selector('#conv-trash-btn') 
      page.should have_selector('#conv-bill-btn') 
      page.should_not have_selector('#conv-pay-btn') 
      page.should_not have_selector('#conv-show-btn') 
    end

    it "marks all posts read", js: true do
      click_on 'Mark All Read'
      page.should have_css('li.active a') 
    end
     
    describe 'show messages' do
      before :each do
        visit conversations_path(status: 'received')
      end

      it "opens messages page" do
        page.should have_selector('#conv-show-btn') 
        page.find('#conv-show-btn').click
        page.should have_content @conversation.pixi_title
      end
    end
     
    describe 'pay invoice' do
      before :each do
        add_invoice
        visit conversations_path(status: 'received')
      end

      it "opens pay invoice page" do
        page.should have_selector('#conv-pay-btn') 
        page.find('#conv-pay-btn').click
        page.should have_content 'Amount Due'
      end
    end
     
    describe 'paid invoice' do
      before :each do
        paid_invoice
        visit conversations_path(status: 'received')
      end

      it { should_not have_selector('#conv-pay-btn') }
    end
     
    describe 'paid invoice after opening messages' do
      before :each do
        add_invoice
        visit conversations_path(status: 'received')
        sleep 5;
      end

      it "opens pay invoice page" do
        page.should have_selector('#conv-pay-btn') 
	@invoice.status = 'paid'; @invoice.save
	sleep 3;
        page.find('#conv-pay-btn').click
        page.should have_content 'Amount Due'
        page.should_not have_content 'Unpaid'
      end
    end
     
    describe 'paid invoice' do
      before :each do
        paid_invoice
        visit conversations_path
      end

      it { should_not have_selector('#conv-pay-btn') }
    end
  end
     
  describe 'Received conversations - ajax', js: true do
    before :each do
      add_conversation
      add_invoice
      visit conversations_path(status: 'received')
      click_on 'Sent'
      click_on 'Received'
    end
    
    it 'shows content' do
      page.should have_link('Mark All Read', href: mark_posts_path)
      page.should have_content @conversation.user.name
      page.should have_content @conversation.listing.title
      page.should have_content @post.content
      page.should have_selector('#conv-trash-btn') 
      page.should have_selector('#conv-pay-btn') 
      page.should_not have_content 'No conversations found' 
    end

    it "pays an invoice" do
      page.should have_selector('#conv-pay-btn') 
      page.find('#conv-pay-btn').click
      page.should have_content 'Amount Due'
    end

  end
     
  describe 'No sent conversations' do
    before :each do 
      visit conversations_path(status: 'received')
    end

    it 'shows no sent conversations', js: true do
      click_on 'Sent'
      page.should_not have_link('Mark All Read', href: mark_posts_path) 
      page.should have_content 'No conversations found' 
    end
  end
     
  describe 'sent conversations' do
    before :each do 
      @reply_listing = FactoryGirl.create :listing, seller_id: @sender.id
      @reply_conv= @reply_listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @user.id, recipient_id: @sender.id
      @reply_post = @reply_conv.posts.create FactoryGirl.attributes_for :post, user_id: @user.id, recipient_id: @sender.id, pixi_id: @listing.pixi_id
      visit conversations_path(status: 'received')
    end

    it 'shows sent conversations', js: true do
      click_on 'Sent'
      page.should_not have_link('Mark All Read', href: mark_posts_path) 
      page.should have_content @reply_conv.recipient.name 
      page.should have_content @reply_conv.listing.title 
      page.should have_content @reply_post.content 
      page.should_not have_content 'No conversations found' 
    end
  end

  describe 'Show Page', js: true do
    before :each do
      add_conversation
      visit conversations_path(status: 'received')
      sleep 5
      page.find("#conv-show-btn", :visible => true).click
    end
    
    it 'shows content' do
      page.should have_content @conversation.user.name
      page.should have_content @conversation.listing.title
      page.should have_content @post.content
    end

    it "can go back to received page" do
      click_on 'Received'
      sleep 5
      page.should have_selector('#conv-show-btn') 
    end

    it "can go back to sent page" do
      click_on 'Sent'
      page.should have_content 'No conversations found' 
    end

    it 'removes last message' do
      page.should have_selector('.msg-trash-btn') 
      page.find(".msg-trash-btn", :visible => true).click
      click_remove_ok
      sleep 3
      expect(Post.where(recipient_status: 'removed').count).to eq 1
      page.should have_content 'No conversations found' 
    end

    it 'removes a message' do
      add_post @conversation; sleep 2
      expect(Post.all.count).to eq 2
      page.should have_selector('.msg-trash-btn') 
      page.find(".msg-trash-btn", :visible => true).click
      click_remove_ok
      sleep 3
      page.should_not have_content 'No conversations found' 
      page.should have_selector('.msg-trash-btn') 
      expect(Post.where(recipient_status: 'active').count).to eq 1
      expect(Post.where(recipient_status: 'removed').count).to eq 1
    end

    context 'replying' do 
      it 'replies to a conversation' do 
        send_reply
      end

      it 'does not reply when new message invalid' do
        expect{
            fill_in 'reply_content', with: nil
            click_send
        }.not_to change(Post,:count).by(1)

        page.should have_content "Content can't be blank"
      end
    end
  end

  describe 'Seller Sold or Removed Pixis', js: true do
    before :each do
      add_conversation
      @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
      visit conversations_path(status: 'received')
      sleep 5
    end

    it 'handles removed pixi' do
      page.should have_selector('#conv-bill-btn') 
      @listing.status = 'removed'; @listing.save
      sleep 2;
      page.find("#conv-bill-btn", :visible => true).click
      page.should have_content NO_INV_PIXI_MSG
    end

    it 'handles sold pixi' do
      page.should have_selector('#conv-bill-btn') 
      @listing.status = 'sold'; @listing.save
      sleep 2;
      page.find("#conv-bill-btn", :visible => true).click
      sleep 2;
      page.should have_content NO_INV_PIXI_MSG
    end
  end

  describe 'Remove Sent Conversation', js: true do
    before :each do
      visit destroy_user_session_path
      sleep 1;
      init_setup @sender
      add_conversation
      visit conversations_path(status: 'sent')
      sleep 5
      page.find("#conv-show-btn", :visible => true).click
    end
    
    it 'shows content' do
      sleep 2;
      page.should have_content @conversation.pixi_title
      page.should have_content @post.content
    end

    it 'removes conversation' do
      page.find("#conv-trash-btn", :visible => true).click
      click_remove_ok
      sleep 3
      page.should have_content 'No conversations found' 
      expect(Conversation.where(status: 'removed').count).to eq 1
    end
  end

  describe 'Show System Messages', js: true do
    before :each do
      add_system_conversation
      visit conversations_path(status: 'received')
    end
    
    it 'shows conversation content' do
      page.should have_selector('#conv-show-btn') 
      page.should have_selector('#conv-trash-btn') 
      page.should_not have_selector('#conv-pay-btn') 
      page.should_not have_selector('#conv-bill-btn') 
    end
    
    it 'shows message content' do
      sleep 5
      page.find("#conv-show-btn", :visible => true).click
      page.should have_selector('#conv-trash-btn') 
      page.should_not have_selector('#conv-pay-btn') 
      page.should_not have_selector('#conv-bill-btn') 
      page.should have_content @conversation.user.name
      page.should have_content @conversation.listing.title
      page.should have_content @post.content
    end

    it 'removes conversation' do
      page.find("#conv-trash-btn", :visible => true).click
      click_remove_ok
      sleep 3
      page.should have_content 'No conversations found' 
      expect(Conversation.where(recipient_status: 'removed').count).to eq 1
    end
  end

  describe 'pagination', js: true do
    before(:each) do 
      5.times { 
        @user = FactoryGirl.create :pixi_user
        @sender = FactoryGirl.create :pixi_user
        @listing = FactoryGirl.create :listing, seller_id: @user.id
        @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @sender.id, recipient_id: @user.id 
        @conversation = @listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: @sender.id, recipient_id: @user.id
        @post = @conversation.posts.create FactoryGirl.attributes_for :post, user_id: @sender.id, recipient_id: @user.id, pixi_id: @listing.pixi_id 
      }
      visit conversations_path(status: 'received')
    end

    let(:first_page)  { Conversation.paginate(page: 1) }
    let(:second_page)  { Conversation.paginate(page: 2) }

    it { should have_selector('div', class: 'pagination') }

    it 'lists each conversation' do
      first_page.each do |conv|
        page.should have_selector('li', :value => conv.id)
      end
    end

    it 'does not list second page for conversation' do
      second_page.each do |conv|
        page.should_not have_selector('li', :value => conv.id)
      end
    end

  end
end
