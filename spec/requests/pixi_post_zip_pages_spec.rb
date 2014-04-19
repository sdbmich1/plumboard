require 'spec_helper'

feature "PixiPostZips" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:submit) { "Submit" }

  before(:each) do
    create :state
    load_zips
  end

  def load_zips
    create :pixi_post_zip
    create :pixi_post_zip, zip: '94108'
    @zip = create :pixi_post_zip, zip: '94103'
  end

  def init_setup usr
    login_as(usr, :scope => :user, :run_callbacks => false)
    @user = usr
  end

  describe 'user makes new request' do
    before do
      init_setup user
      visit check_pixi_post_zips_path
    end

    it 'shows content' do
      page.should have_selector('title', text: 'PixiPost Zipcheck')
      page.should have_content "My PixiPosts" 
      page.should have_content "Move Your Stuff" 
      page.should have_link "Active", href: seller_pixi_posts_path(status: 'active')
      page.should have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      page.should have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      page.should have_content "Enter Your Zip Code" 
      page.should have_selector('#zip_code')
    end

    it "finds valid zip" do
      expect { 
        fill_in 'zip_code', with: '94103'
	click_button submit
      }.not_to change(PixiPost, :count)

      page.should have_content "PixiPost" 
      page.should have_content "Requested By: " 
      page.should have_content @user.name
      page.should have_content @zip.city
      page.should have_content @zip.zip
    end

    it "does not find valid zip" do
      expect { 
        fill_in 'zip_code', with: '48103'
	click_button submit
      }.not_to change(PixiPost, :count)

      page.should_not have_content "Requested By: " 
      page.should have_content "#{PIXI_POST_ZIP_ERROR}"
      page.should have_content "Enter Your Zip Code" 
    end
  end

  describe "Views PixiPosts" do 
    before do
      init_setup user
      @pixan = create :pixi_user, user_type_code: 'PX'
      @listing = FactoryGirl.create :listing, seller_id: @user.id, pixan_id: @pixan.id
      @pixi_post = @user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post, description: 'tire rims')
      @scheduled = @user.pixi_posts.create FactoryGirl.attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days,
        appt_time: Time.now+3.days, description: 'xbox 360'
      @completed = @user.pixi_posts.create FactoryGirl.attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days, 
        appt_time: Time.now+3.days, completed_date: Time.now+3.days, pixi_id: @listing.pixi_id, description: 'rocking chair'
    end

    it 'shows active content' do
      visit check_pixi_post_zips_path
      page.find('#active-posts').click
      page.should have_link("#{@pixi_post.id}", href: pixi_post_path(@pixi_post))
      page.should_not have_link("#{@scheduled.id}", href: pixi_post_path(@scheduled))
      page.should_not have_link("#{@completed.id}", href: pixi_post_path(@completed))
      page.should have_selector('title', text: 'My PixiPosts')
      page.should have_link "Submitted"
      page.should have_link "Scheduled"
      page.should have_link "Completed"
      page.should have_content "Preferred Date"
      page.should have_content "Preferred Time"
      page.should_not have_content "Scheduled Date"
      page.should_not have_content "Scheduled Time"
      page.should_not have_content "Completed Date"
      page.should_not have_content "Completed Time"
      page.should have_content "My PixiPosts"
      page.should have_content "Seller Name" 
    end

    it "displays scheduled posts" do
      visit check_pixi_post_zips_path
      page.find('#schd-posts').click
      page.should_not have_content "Preferred Date"
      page.should_not have_content "Preferred Time"
      page.should have_content "Scheduled Date"
      page.should have_content "Scheduled Time"
      page.should_not have_content "Completed Date"
      page.should_not have_content "Completed Time"
      page.should_not have_content @pixi_post.description
      page.should_not have_content @completed.description
      page.should have_content @scheduled.description
      page.should_not have_content 'No posts found.'
    end

    it "displays completed posts" do
      visit check_pixi_post_zips_path
      page.find('#comp-posts').click
      page.should_not have_content "Preferred Date"
      page.should_not have_content "Preferred Time"
      page.should_not have_content "Scheduled Date"
      page.should_not have_content "Scheduled Time"
      page.should have_content "Completed Date"
      page.should have_content "Completed Time"
      page.should_not have_content @pixi_post.description
      page.should_not have_content @scheduled.description
      page.should have_content @completed.description
      page.should_not have_content 'No posts found.'
    end
  end

end

