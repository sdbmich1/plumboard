require 'spec_helper'

feature "PixiPosts" do
  subject { page }
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:contact_user) { FactoryGirl.create(:contact_user) }
  let(:editor) { FactoryGirl.create :editor, first_name: 'Steve', confirmed_at: Time.now }
  let(:submit) { "Save" }

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

  def click_cancel_ok
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.accept
  end

  def click_cancel_cancel
    click_link 'Cancel'
    page.driver.browser.switch_to.alert.dismiss
  end

  def click_remove_ok
    click_link 'Remove'
    page.driver.browser.switch_to.alert.accept
  end

  def click_remove_cancel
    click_link 'Remove'
    page.driver.browser.switch_to.alert.dismiss
  end

  def set_pixan
    page.execute_script %Q{ $('#pixan_id').val("#{editor.id}") }
  end

  def set_pixi
    page.execute_script %Q{ $('#pixi_post_pixi_id').val("#{@listing.pixi_id}") }
  end

  def add_data
    pref_data
    fill_in 'pixi_post_value', with: 200.00
    fill_in 'description', with: "xbox 360 box."
  end

  def add_phone
    fill_in 'pixi_post_home_phone', with: '4152419755'
    fill_in 'pixi_post_mobile_phone', with: '4152419733'
  end

  def user_data
    user_city_data
    add_phone
  end

  def user_city_data
    fill_in 'pixi_post_address', with: '251 Connecticut'
    fill_in 'pixi_post_city', with: 'San Francisco'
  end

  def user_data_with_state
    user_data
    select("California", :from => "pixi_post_state")
    fill_in 'pixi_post_zip', with: '94103'
  end
  
  def alt_data
    fill_in 'alt-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
    select('2:00 PM', :from => 'alt-time')
  end
  
  def pref_data
    fill_in 'pref-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
    select('1:00 PM', :from => 'pref-time')
    select("2", :from => "post_qty")
  end

  describe 'user opens a new pixi post' do
    before do
      init_setup user
      visit new_pixi_post_path(zip: '90201')
    end

    it "Opens from menu" do
      expect { 
	  click_link 'By Us'
      }.not_to change(PixiPost, :count)

      page.should have_content "PixiPost" 
      page.should have_content "Requested By: " 
      page.should have_content @user.name
    end
  end

  describe 'user w/o adds a new pixi post' do
    before do
      init_setup user
      visit new_pixi_post_path(zip: '94103') 
    end

    it 'show content' do
      page.should have_content "PixiPost"
      page.should have_content "Requested By: "
      page.should have_content @user.name
      page.should have_content @zip.city
      page.should have_content @zip.state
      page.should have_content @zip.zip
      page.should have_selector('.grp-hdr', visible: false)
      page.should have_link('Cancel', href: root_path)
      page.should have_button('Save')
    end

    it "creates a pixi post" do
      add_data
      user_data_with_state
      expect { 
	  click_button submit
      }.to change(PixiPost, :count).by(1)

      page.should have_content "PixiPost Request"
      page.should have_content @user.name
    end
  end

  describe 'user w/ address adds a new pixi post' do
    before do
      init_setup contact_user
      visit new_pixi_post_path(zip: '90201') 
    end

    it 'show content' do
      page.should have_content "PixiPost"
      page.should have_content "Requested By: "
      page.should have_content "Address Information"
      page.should have_content @user.contacts[0].address
      page.should have_content @user.contacts[0].city
      page.should have_content @user.contacts[0].state
      page.should have_content @user.contacts[0].zip
      page.should have_content @user.name
      page.should have_link('Cancel', href: root_path)
      page.should have_button('Save')
    end

    it "creates a pixi post" do
      add_data
      expect { 
	  click_button submit; sleep 2
      }.to change(PixiPost, :count).by(1)

      page.should have_content "PixiPost Request"
    end
  end

  describe "Create with invalid information" do
    before do
      init_setup user
      visit new_pixi_post_path 
    end

    it "must have a preferred date" do
      fill_in 'pixi_post_value', with: 200.00
      fill_in 'description', with: "xbox 360 box."
      user_data_with_state
      expect { click_button submit }.not_to change(PixiPost, :count)
      page.should have_content "Preferred date is not a valid date"
    end

    it "must have an estimated value" do
      pref_data
      expect { click_button submit }.not_to change(PixiPost, :count)
      page.should have_content "Value can't be blank"
    end

    it "must have a description" do
      pref_data
      fill_in 'pixi_post_value', with: 200.00
      user_data_with_state
      expect { click_button submit }.not_to change(PixiPost, :count)
      page.should have_content "Description can't be blank"
    end

    it "must have an address" do
      add_data
      expect { click_button submit }.not_to change(PixiPost, :count)
      page.should have_content "Address can't be blank"
    end

    it "must have a city" do
      add_data
      fill_in 'pixi_post_address', with: '251 Connecticut'
      expect { click_button submit }.not_to change(PixiPost, :count)
      page.should have_content "City can't be blank"
    end

    it "must have a state" do
      add_data
      user_city_data
      expect { click_button submit }.not_to change(PixiPost, :count)
      page.should have_content "State can't be blank"
    end

    it "must have a zip" do
      add_data
      user_city_data
      select("California", :from => "pixi_post_state")
      expect { click_button submit }.not_to change(PixiPost, :count)
      page.should have_content "Zip can't be blank"
    end

    it "must have a valid zip" do
      add_data
      user_city_data
      select("California", :from => "pixi_post_state")
      fill_in 'pixi_post_zip', with: '94113'
      add_phone
      expect { click_button submit }.not_to change(PixiPost, :count)
      page.should have_content "Zip not in current PixiPost service area"
    end
  end

  describe "View PixiPosts" do 
    before do
      init_setup user
      @pixi_post = @user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post)
      visit root_path 
    end

    it "Opens from menu" do
      expect { 
	  click_link 'My PixiPosts'
      }.not_to change(PixiPost, :count)

      page.should have_selector('title', text: 'My PixiPosts')
      page.should have_content "PixiPost" 
      page.should have_content "Seller Name" 
      page.should have_link "Active", href: seller_pixi_posts_path(status: 'active')
      page.should have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      page.should have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      page.should have_content @pixi_post.id
      page.should have_content @pixi_post.description
      page.should have_content user.name
    end
  end

  describe "Seller views active PixiPosts" do 
    let(:pixan) { FactoryGirl.create :pixi_user }

    before do
      init_setup user
      load_zips
      @listing = FactoryGirl.create :listing, seller_id: @user.id 
      @pixi_post = @user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post, description: 'tire rims')
      @scheduled = @user.pixi_posts.create FactoryGirl.attributes_for :pixi_post, pixan_id: pixan.id, appt_date: Time.now+3.days,
        appt_time: Time.now+3.days, description: 'xbox 360'
      @completed = @user.pixi_posts.create FactoryGirl.attributes_for :pixi_post, pixan_id: pixan.id, appt_date: Time.now+3.days, 
        appt_time: Time.now+3.days, completed_date: Time.now+3.days, pixi_id: @listing.pixi_id, description: 'rocking chair'
      visit seller_pixi_posts_path(status: 'active') 
    end

    it 'show content' do
      page.should have_link("#{@pixi_post.id}", href: pixi_post_path(@pixi_post))
      page.should_not have_link("#{@scheduled.id}", href: pixi_post_path(@scheduled))
      page.should_not have_link("#{@completed.id}", href: pixi_post_path(@completed))
      page.should have_selector('title', text: 'My PixiPosts')
      page.should have_link "Active"
      page.should have_link "Scheduled"
      page.should have_link "Completed"
      page.should have_content "My PixiPosts"
      page.should have_content "Seller Name" 
    end

    it "displays scheduled posts", js: true do
      page.find('#schd-posts').click
      page.should_not have_content @pixi_post.description
      page.should_not have_content @completed.description
      page.should have_content @scheduled.description
      page.should_not have_content 'No posts found.'
    end

    it "displays completed posts", js: true do
      page.find('#comp-posts').click
      page.should_not have_content @pixi_post.description
      page.should_not have_content @scheduled.description
      page.should have_content @completed.description
      page.should_not have_content 'No posts found.'
    end

    it "clicks to open a pixipost" do
      expect { 
        click_on "#{@pixi_post.id}"
      }.not_to change(PixiPost, :count)

      page.should have_content "PixiPost Request"
      page.should have_link 'Edit', href: edit_pixi_post_path(@pixi_post) 
      page.should have_link 'Remove', href: pixi_post_path(@pixi_post) 
      page.should have_link 'Done', href: seller_pixi_posts_path(status: 'active') 
      page.should have_content @pixi_post.description
      page.should have_content user.name
    end

    it "cancel remove pixi", js: true do
      expect { 
        click_on "#{@pixi_post.id}"
      }.not_to change(PixiPost, :count)

      click_remove_cancel
      page.should have_content "PixiPost Request" 
    end

    it "deletes a pixi", js: true do
      expect{
        click_on "#{@pixi_post.id}"
        click_remove_ok; sleep 3;
      }.to change(PixiPost,:count).by(-1)

      page.should have_content "My PixiPosts" 
      page.should have_content "No posts found." 
    end
  end

  describe "Seller edits a PixiPost" do 
    before do
      init_setup user
      load_zips
      @pixi_post = @user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post)
      visit seller_pixi_posts_path(status: 'active') 
    end

    it 'show content' do
      page.should have_link "Active", href: seller_pixi_posts_path(status: 'active')
      page.should have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      page.should have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      page.should have_content "My PixiPosts"
    end

    it "clicks to open a pixipost" do
      expect { 
        click_on "#{@pixi_post.id}"
	click_link 'Edit'
      }.not_to change(PixiPost, :count)

      page.should have_selector('title', text: 'Edit PixiPost') 
      page.should have_content "Address Information"
      page.should_not have_content "Appointment Date"
      page.should have_link 'Cancel', href: seller_pixi_posts_path(status: 'active') 
      page.should have_button('Save') 
    end

    it "changes a pixi description" do
      expect{
        click_on "#{@pixi_post.id}"
	click_link 'Edit'
	fill_in 'description', with: "Acoustic bass"
        click_button submit
      }.to change(PixiPost,:count).by(0)

      page.should have_content 'PixiPost Request'
      page.should have_content "Acoustic bass" 
    end
  end

  describe "Editor edits a PixiPost" do 
    before do
      load_zips
      init_setup editor
      @pixi_post = user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post)
      visit edit_pixi_post_path(@pixi_post)
    end

    it "opens pixipost edit page" do
      page.should have_selector('title', text: 'Edit PixiPost') 
      page.should_not have_link "Active", href: seller_pixi_posts_path(status: 'active')
      page.should_not have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      page.should_not have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      page.should have_link "Active", href: pixi_posts_path(status: 'active')
      page.should have_link "Scheduled", href: pixi_posts_path(status: 'scheduled')
      page.should have_link "Completed", href: pixi_posts_path(status: 'completed')
      page.should have_content "Request Information"
      page.should have_content "Address Information"
      page.should have_content "Appointment Date"
      page.should have_selector('#pixan_id', visible: true) 
      page.should have_link 'Cancel', href: pixi_posts_path(status: 'active') 
      page.should_not have_link 'Cancel', href: seller_pixi_posts_path(status: 'active') 
      page.should have_button('Save') 
    end

    it "sets appointment date", js: true do
      expect{
        fill_in 'appt-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'appt-tm')
	set_pixan
        click_button submit; sleep 2
      }.to change(PixiPost,:count).by(0)

      page.should have_content 'PixiPost Request'
      page.should have_content 'Appointment Date'
      page.should have_content 'Appointment Time'
    end

    it "does not set appt date", js: true do
      expect{
        fill_in 'appt-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'appt-tm')
        click_button submit; sleep 2
      }.to change(PixiPost,:count).by(0)
      page.should have_content "Pixan can't be blank"
    end
  end

  describe "Editor closes a PixiPost" do 
    before do
      load_zips
      init_setup editor
      @pixi_post = user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post)
      @listing = FactoryGirl.create :listing, seller_id: user.id, status: 'active' 
      visit edit_pixi_post_path(@pixi_post)
    end

    it "does not set completed date", js: true do
      expect{
        fill_in 'cmp-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'cmp-tm')
	set_pixan
        click_button submit; sleep 2
      }.to change(PixiPost,:count).by(0)
      page.should have_content "Pixi can't be blank"
    end

    it "sets completed date", js: true do
      expect{
        fill_in 'appt-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'appt-tm')
        fill_in 'cmp-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'cmp-tm')
	set_pixan
        select(@listing.title, :from => 'pixi_post_pixi_id')
        click_button submit; sleep 2
      }.to change(PixiPost,:count).by(0)

      page.should have_content 'PixiPost Request'
      page.should have_content 'Completed Date'
      page.should have_content 'Completed Time'
    end
  end

  describe "Editor views a PixiPost" do 
    before do
      load_zips
      init_setup editor
      @pixi_post = user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post)
      @listing = FactoryGirl.create(:listing, seller_id: user.id) 
      visit pixi_posts_path(status: 'active') 
    end

    it 'show content' do
      page.should have_link("#{@pixi_post.id}", href: pixi_post_path(@pixi_post))
      page.should have_selector('title', text: 'PixiPosts')
      page.should_not have_selector('title', text: 'My PixiPosts')
      page.should have_content "PixiPost"
      page.should have_content "Seller Name" 
    end

    it "clicks to open a pixipost" do
      expect { 
        click_on "#{@pixi_post.id}"
      }.not_to change(PixiPost, :count)

      page.should have_content "PixiPosts"
      page.should have_content "PixiPost Request"
      page.should have_content @pixi_post.description
      page.should have_content user.name
      page.should have_link 'Edit', href: edit_pixi_post_path(@pixi_post) 
      page.should_not have_link 'Remove', href: pixi_post_path(@pixi_post) 
      # page.should have_selector('#rm-btn', visible: false) 
      page.should have_link 'Done', href: pixi_posts_path(status: 'active') 
    end
  end

  describe "Editor cancels a PixiPost" do 
    before do
      load_zips
      init_setup editor
      @pixi_post = user.pixi_posts.create FactoryGirl.attributes_for(:pixi_post)
      visit edit_pixi_post_path(@pixi_post) 
    end

    it "cancels pixipost edit", js: true do
      click_cancel_ok; sleep 2
      page.should have_content "PixiPosts" 
    end

    it "cancels edit of pixipost", js: true do
      click_cancel_cancel
      page.should have_content "Edit PixiPost" 
    end
  end

end
