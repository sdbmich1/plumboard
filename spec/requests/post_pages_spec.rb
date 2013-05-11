require 'spec_helper'

feature "Posts" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
    @sender = FactoryGirl.create :pixi_user, first_name: 'Tom', last_name: 'Davis'
    @listing = FactoryGirl.create :listing, seller_id: @user.id
    @post = FactoryGirl.create :post, user: @sender, recipient: @user, listing: @listing, pixi_id: @listing.pixi_id
  end

  def click_reply
    click_on 'Reply'
    sleep 3
  end

  describe 'unread posts' do
    before :each do
      visit listings_path 
      click_on 'notice-btn'
    end

    it { should have_selector('title', :text => full_title('Read Posts')) }
    it { should have_content @post.user.name }

    it "should reply to a post", js: true do
      expect{
      	  fill_in 'reply_content', with: "I'm interested in this pixi. Please contact me." 
          click_reply
      }.to change(Post,:count).by(1)

      page.should_not have_content @post.listing.title
    end
     
    it "should not reply to a post", js: true do
      expect{
	  fill_in 'reply_content', with: nil
          click_reply
      }.not_to change(Post,:count).by(1)

      page.should have_content "Content can't be blank"
    end
  end
     
  describe 'received posts', js: true do
    before :each do
      visit listings_path 
      click_on 'notice-btn'
      click_on 'Received'
    end
    
    it { should have_content @post.user.name }
    it { should have_content @post.listing.title }
    it { should have_content @post.content }

    it "should reply to a post" do
      expect{
      	  fill_in 'reply_content', with: "I'm interested in this pixi. Please contact me." 
          click_reply
      }.to change(Post,:count).by(1)

      page.should_not have_content @post.listing.title
    end
     
    it "should not reply to a post" do
      expect{
	  fill_in 'reply_content', with: nil
          click_reply
      }.not_to change(Post,:count).by(1)

      page.should have_content "Content can't be blank"
    end
  end
     
  describe 'sent posts', js: true do
    before :each do 
      @reply_post = FactoryGirl.create :post, user: @user, recipient: @sender, listing: @listing, pixi_id: @listing.pixi_id
      visit listings_path 
      click_on 'notice-btn'
      click_on 'Sent'
    end

    it { should have_content @reply_post.user.name }
    it { should have_content @reply_post.listing.title }
    it { should have_content @reply_post.content }
  end
end
