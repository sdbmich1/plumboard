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
end

