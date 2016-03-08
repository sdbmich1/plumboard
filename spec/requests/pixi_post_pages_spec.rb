require 'spec_helper'
require 'rake'

feature "PixiPosts" do
  subject { page }
  let(:user) { create(:pixi_user) }
  let(:contact_user) { create(:contact_user) }
  let(:admin) {create :admin, user_type_code: 'AD', confirmed_at: Time.now}
  let(:pixter) { create :pixter, user_type_code: 'PT', confirmed_at: Time.now }
  let(:pixter2) { create :pixter, user_type_code: 'PT', confirmed_at: Time.now }
  let(:editor) { create :editor, first_name: 'Steve', user_type_code: 'PX', confirmed_at: Time.now }
  let(:commit) { "Done" }
  let(:submit) { "Register" } 

  before(:each) do
    create_user_types
    load_zips
  end

  def load_zips
    create :state
    create :pixi_post_zip
    create :pixi_post_zip, zip: '94108'
    @zip = create :pixi_post_zip, zip: '94103'
  end

  def set_pixan
    #page.execute_script %Q{ $('#pixan_id').val("#{editor.id}") }
    select(editor.name, :from => 'pixan_id')
  end

  def set_pixi
    page.execute_script %Q{ $('#listing_tokens').val("['#{@listing.pixi_id}']") }
    # page.execute_script %Q{ $('#pixi_post_pixi_id').val("#{@listing.pixi_id}") }
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
    dt =  Date.today + 4.days
    fill_in 'alt-dt', with: dt.strftime('%m/%d/%Y')
    select('2:00 PM', :from => 'alt-time')
  end
  
  def pref_data
    dt =  Date.today + 4.days
    fill_in 'pref-dt', with: dt.strftime('%m/%d/%Y')
    select('1:00 PM', :from => 'pref-time')
    select("2", :from => "post_qty")
  end

  def request_post
    add_data
    user_data
    expect { 
      click_button commit; sleep 3
      expect(page).to have_content "Sign in"
    }.to change(PixiPost, :count).by(1)
  end

  describe 'user w/o address adds a new pixi post' do
    before do
      init_setup user
      visit new_pixi_post_path(zip: '94103') 
    end

    it 'show content', js: true do
      # page.should have_content "PixiPost"
      expect(page).to have_content "Requested By: "
      expect(page).to have_content @user.name
      expect(page).to have_content @zip.city
      expect(page).to have_content @zip.state
      expect(page).to have_content @zip.zip
      expect(page).to have_selector('.grp-hdr', visible: false)
      expect(page).to have_link('Cancel')
      expect(page).to have_button('Done')
    end

    it "creates a pixi post", js: true do
      add_data
      user_data_with_state
      expect { 
	click_button commit; sleep 3
        expect(page).to have_content "PixiPost Request"
        expect(page).to have_content @user.name
      }.to change(PixiPost, :count).by(1)
    end
  end

  describe 'user w/ address adds a new pixi post' do
    before do
      init_setup contact_user
      visit new_pixi_post_path(zip: '90201') 
    end

    it 'show content' do
      # page.should have_content "PixiPost"
      expect(page).to have_content "Requested By: "
      expect(page).to have_content "Address Information"
      expect(page).to have_content @user.contacts[0].address
      expect(page).to have_content @user.contacts[0].city
      expect(page).to have_content @user.contacts[0].state
      expect(page).to have_content @user.contacts[0].zip
      expect(page).to have_content @user.name
      expect(page).to have_link('Cancel')
      expect(page).to have_button('Done')
    end

    it "creates a pixi post", js: true do
      add_data
      expect { 
	click_button commit; sleep 3
        expect(page).to have_content "PixiPost Request"
      }.to change(PixiPost, :count).by(1)
    end
  end

  describe 'Guest adds a new pixi post' do
    before do
      create_user_types
      visit new_pixi_post_path(zip: '90201') 
    end

    it 'show content' do
      expect(page).to have_content "PixiPost"
      expect(page).to have_content "Address Information"
      expect(page).to have_content '90201'
      expect(page).to have_link('Cancel')
      expect(page).to have_button('Done')
    end

    it "creates a pixi post and signs in", js: true do
      request_post
      @user = create :pixi_user, confirmed_at: Time.now
      user_login @user
      expect(page).to have_content "PixiPost Request"
      expect(page).to have_content @user.name
    end

    it "creates a pixi post and signs in w/ FB", js: true do
      request_post
      omniauth
      click_on "fb-btn"
      expect(page).to have_content "PixiPost Request"
      expect(page).to have_content 'Bob Smith'
    end
  end

  describe "Create with invalid information", js: true do
    before do
      init_setup user
      visit new_pixi_post_path 
    end

    it "must have a preferred date" do
      fill_in 'pixi_post_value', with: 200.00
      fill_in 'description', with: "xbox 360 box."
      user_data_with_state
      expect { click_button commit }.not_to change(PixiPost, :count)
      expect(page).to have_content "Preferred date is not a valid date"
    end

    it "must have an estimated value" do
      pref_data
      expect { click_button commit }.not_to change(PixiPost, :count)
      expect(page).to have_content "Value can't be blank"
    end

    it "must have a description" do
      pref_data
      fill_in 'pixi_post_value', with: 200.00
      user_data_with_state
      expect { click_button commit }.not_to change(PixiPost, :count)
      expect(page).to have_content "Description can't be blank"
    end

    it "must have an address" do
      add_data
      expect { click_button commit }.not_to change(PixiPost, :count)
      expect(page).to have_content "Address can't be blank"
    end

    it "must have a city" do
      add_data
      fill_in 'pixi_post_address', with: '251 Connecticut'
      expect { click_button commit }.not_to change(PixiPost, :count)
      expect(page).to have_content "City can't be blank"
    end

    it "must have a state" do
      add_data
      user_city_data
      expect { click_button commit }.not_to change(PixiPost, :count)
      expect(page).to have_content "State can't be blank"
    end

    it "must have a zip" do
      add_data
      user_city_data
      select("California", :from => "pixi_post_state")
      expect { click_button commit }.not_to change(PixiPost, :count)
      expect(page).to have_content "Zip can't be blank"
    end

    it "must have a valid zip" do
      add_data
      user_city_data
      select("California", :from => "pixi_post_state")
      fill_in 'pixi_post_zip', with: '94113'
      add_phone
      expect { click_button commit }.not_to change(PixiPost, :count)
      expect(page).to have_content "Zip not in current PixiPost service area"
    end
  end

  describe "View PixiPosts", seller: true do 
    before do
      init_setup user
      @pixi_post = @user.pixi_posts.create attributes_for(:pixi_post)
      visit root_path 
    end

    it "Opens from menu" do
      expect { 
	  click_link 'My PixiPosts'
      }.not_to change(PixiPost, :count)

      expect(page).to have_selector('title', text: 'My PixiPosts')
      expect(page).to have_content "PixiPost" 
      expect(page).to have_content "Seller Name" 
      expect(page).to have_link "Submitted", href: seller_pixi_posts_path(status: 'active')
      expect(page).to have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      expect(page).to have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      expect(page).to have_content @pixi_post.id
      expect(page).to have_content @pixi_post.description
      expect(page).to have_content user.name
    end
  end

  def post_setup usr
    init_setup usr
    @pixan = create :pixi_user, user_type_code: 'PX'
    @listing = create :listing, seller_id: @user.id, pixan_id: @pixan.id
    @pixi_post = @user.pixi_posts.create attributes_for(:pixi_post, description: 'tire rims')
    @scheduled = @user.pixi_posts.create attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days,
        appt_time: Time.now+3.days, description: 'xbox 360'
    @completed = @user.pixi_posts.build attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days, 
        appt_time: Time.now+3.days, completed_date: Time.now+3.days, description: 'rocking chair'
    @completed.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing.pixi_id 
    @completed.save!
    visit seller_pixi_posts_path(status: 'active') 
  end

  def sched_post flg=true
    visit pixi_post_path(@scheduled)
    expect(page).to have_content "PixiPost Request"
    expect(page).not_to have_link 'Edit', href: edit_pixi_post_path(@scheduled) if flg
    expect(page).to have_link 'Reschedule', href: reschedule_pixi_post_path(@scheduled) if flg 
    expect(page).to have_link 'Remove', href: pixi_post_path(@scheduled) 
    expect(page).to have_link 'Done', href: seller_pixi_posts_path(status: 'active') 
    expect(page).to have_content @scheduled.description
    expect(page).to have_content @pixan.name
  end

  describe "Seller views PixiPosts", seller: true do 
    before do
      post_setup user
    end

    it 'shows active content' do
      expect(page).to have_link("#{@pixi_post.id}", href: pixi_post_path(@pixi_post))
      expect(page).not_to have_link("#{@scheduled.id}", href: pixi_post_path(@scheduled))
      expect(page).not_to have_link("#{@completed.id}", href: pixi_post_path(@completed))
      expect(page).to have_selector('title', text: 'My PixiPosts')
      expect(page).to have_link "Submitted"
      expect(page).to have_link "Scheduled"
      expect(page).to have_link "Completed"
      expect(page).to have_content "Preferred Date"
      expect(page).to have_content "Preferred Time"
      expect(page).not_to have_content "Scheduled Date"
      expect(page).not_to have_content "Scheduled Time"
      expect(page).not_to have_content "Completed Date"
      expect(page).not_to have_content "Completed Time"
      expect(page).to have_content "My PixiPosts"
      expect(page).to have_content "Seller Name" 
      expect(page).not_to have_content "Pixter Name" 
    end

    it "displays scheduled posts", js: true do
      page.find('#schd-posts').click
      expect(page).not_to have_content "Preferred Date"
      expect(page).not_to have_content "Preferred Time"
      expect(page).to have_content "Scheduled Date"
      expect(page).to have_content "Scheduled Time"
      expect(page).not_to have_content "Completed Date"
      expect(page).not_to have_content "Completed Time"
      expect(page).not_to have_content @pixi_post.description
      expect(page).not_to have_content @completed.description
      expect(page).to have_content @scheduled.description
      expect(page).not_to have_content 'No posts found.'
      expect(page).not_to have_content "Seller Name" 
      expect(page).to have_content "Pixter Name" 
    end

    it "displays completed posts", js: true do
      page.find('#comp-posts').click
      expect(page).not_to have_content "Preferred Date"
      expect(page).not_to have_content "Preferred Time"
      expect(page).not_to have_content "Scheduled Date"
      expect(page).not_to have_content "Scheduled Time"
      expect(page).to have_content "Completed Date"
      expect(page).to have_content "Completed Time"
      expect(page).not_to have_content @pixi_post.description
      expect(page).not_to have_content @scheduled.description
      expect(page).to have_content @completed.description
      expect(page).not_to have_content 'No posts found.'
      expect(page).not_to have_content "Seller Name" 
      expect(page).to have_content "Pixter Name" 
    end

    it "clicks to open a scheduled pixipost", js: true do
      sched_post 
    end

    it "reschedules a scheduled pixipost", js: true do
      visit reschedule_pixi_post_path(@scheduled)
      expect(page).to have_content "Requested By: "
      expect(page).to have_content @user.name
      expect { 
        pref_data
        alt_data
	click_button commit; sleep 3
        expect(page).to have_content "PixiPost Request"
        expect(page).to have_content @user.name
      }.to change(PixiPost, :count).by(1)
      expect(PixiPost.where(id: @scheduled.id).count).to eq(0)
    end

    it "clicks to open a completed pixipost" do
      visit pixi_post_path(@completed)
      expect(page).to have_content "PixiPost Request"
      expect(page).not_to have_link 'Edit', href: edit_pixi_post_path(@completed) 
      expect(page).not_to have_link 'Reschedule', href: reschedule_pixi_post_path(@completed) 
      expect(page).not_to have_link 'Remove', href: pixi_post_path(@completed) 
      expect(page).to have_link 'Done', href: seller_pixi_posts_path(status: 'active') 
      expect(page).to have_content @completed.description
      expect(page).to have_content @pixan.name
    end

    it "clicks to open a pixipost" do
      expect { 
        click_on "#{@pixi_post.id}"
      }.not_to change(PixiPost, :count)

      expect(page).to have_content "PixiPost Request"
      expect(page).to have_link 'Edit', href: edit_pixi_post_path(@pixi_post) 
      expect(page).not_to have_link 'Reschedule', href: reschedule_pixi_post_path(@scheduled) 
      expect(page).to have_link 'Remove', href: pixi_post_path(@pixi_post) 
      expect(page).to have_link 'Done', href: seller_pixi_posts_path(status: 'active') 
      expect(page).to have_content @pixi_post.description
      expect(page).to have_content user.name
    end

    it "cancel remove pixi", js: true do
      expect { 
        click_on "#{@pixi_post.id}"
      }.not_to change(PixiPost, :count)

      click_remove_cancel
      expect(page).to have_content "PixiPost Request" 
    end

    it "deletes a pixi", js: true do
      expect{
        click_on "#{@pixi_post.id}"
        click_remove_ok
      }.to change(PixiPost,:count).by(-1)

      expect(page).to have_content "My PixiPosts" 
      expect(page).to have_content "No posts found." 
    end
  end

  describe "Admin views PixiPosts", admin: true do 
    before do
      post_setup admin
    end

    it "clicks to open a scheduled pixipost" do
      sched_post false
    end
  end

  describe "Seller edits a PixiPost", seller: true do 
    before do
      init_setup user
      @pixi_post = @user.pixi_posts.create attributes_for(:pixi_post)
      visit seller_pixi_posts_path(status: 'active') 
    end

    it 'shows active content' do
      expect(page).to have_link "Submitted", href: seller_pixi_posts_path(status: 'active')
      expect(page).to have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      expect(page).to have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      expect(page).to have_content "Preferred Date"
      expect(page).to have_content "Preferred Time"
      expect(page).to have_content "Seller Name"
      expect(page).not_to have_content "Pixter Name"
      expect(page).not_to have_content "Scheduled Date"
      expect(page).not_to have_content "Scheduled Time"
      expect(page).not_to have_content "Completed Date"
      expect(page).not_to have_content "Completed Time"
      expect(page).to have_content "My PixiPosts"
    end

    it 'shows scheduled content', js: true do
      @pixan = create :pixi_user
      @post = @user.pixi_posts.create attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Date.today+3.days, 
        appt_time: Time.now+3.days
      click_link 'Scheduled'
      expect(page).to have_link "Submitted", href: seller_pixi_posts_path(status: 'active')
      expect(page).to have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      expect(page).to have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      expect(page).not_to have_content "Preferred Date"
      expect(page).not_to have_content "Preferred Time"
      expect(page).to have_content "Scheduled Date"
      expect(page).to have_content "Scheduled Time"
      expect(page).not_to have_content "Completed Date"
      expect(page).not_to have_content "Completed Time"
      expect(page).not_to have_content "Seller Name"
      expect(page).to have_content "Pixter Name"
      expect(page).to have_content "My PixiPosts"
      expect(page).not_to have_content "No posts found"
      expect(page).to have_content @post.pixter_name
      expect(page).to have_content @post.description
    end

    it "clicks to open a pixipost" do
      expect { 
        click_on "#{@pixi_post.id}"
	      click_link 'Edit'
      }.not_to change(PixiPost, :count)

      expect(page).to have_selector('title', text: 'Edit PixiPost') 
      expect(page).to have_content "Address Information"
      expect(page).not_to have_content "Appointment Date"
      expect(page).to have_link 'Cancel', href: seller_pixi_posts_path(status: 'active') 
      expect(page).to have_button('Done') 
    end

    it "changes a pixi description", js: true do
      expect{
        click_on "#{@pixi_post.id}"
	      click_link 'Edit'
	      fill_in 'description', with: "Acoustic bass"
        click_button commit
      }.to change(PixiPost,:count).by(0)

      expect(page).to have_content 'PixiPost Request'
      expect(page).to have_content "Acoustic bass" 
    end
  end

  describe "Editor edits a PixiPost", admin: true do 
    before do
      init_setup editor
      @pixi_post = user.pixi_posts.create attributes_for(:pixi_post)
      visit edit_pixi_post_path(@pixi_post)
    end

    it "opens pixipost edit page" do
      expect(page).to have_selector('title', text: 'Edit PixiPost') 
      expect(page).not_to have_link "Submitted", href: seller_pixi_posts_path(status: 'active')
      expect(page).not_to have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      expect(page).not_to have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      expect(page).to have_link "Submitted", href: pixi_posts_path(status: 'active')
      expect(page).to have_link "Scheduled", href: pixi_posts_path(status: 'scheduled')
      expect(page).to have_link "Completed", href: pixi_posts_path(status: 'completed')
      expect(page).to have_content "Request Information"
      expect(page).to have_content "Address Information"
      expect(page).to have_content "Appointment Date"
      expect(page).to have_selector('#pixan_id', visible: true) 
      expect(page).to have_link 'Cancel', href: pixi_posts_path(status: 'active') 
      expect(page).not_to have_link 'Cancel', href: seller_pixi_posts_path(status: 'active') 
      expect(page).to have_button('Done') 
    end

    it "sets appointment date", js: true do
      expect{
        fill_in 'appt-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'appt-tm')
	set_pixan
        click_button commit; sleep 2
      }.to change(PixiPost,:count).by(0)

      expect(page).to have_content user.name
      expect(page).to have_content 'PixiPost Request'
      expect(page).to have_content 'Appointment Date'
      expect(page).to have_content 'Appointment Time'
    end

    it "does not set appt date", js: true do
      expect{
        fill_in 'appt-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'appt-tm')
        click_button commit; sleep 2
      }.to change(PixiPost,:count).by(0)
      expect(page).to have_content "Pixan can't be blank"
    end
  end

  def fill_token_input(locator, options)
    raise "Must pass a hash containing 'with'" unless options.is_a?(Hash) && options.has_key?(:with)
    page.execute_script %Q{$('#{locator}').val('#{options[:with]}').keydown()}
    sleep(5)
    find(:xpath, "//div[@class='token-width']/ul/li[contains(string(),'#{options[:with]}')]").click
  end

  describe "Editor closes a PixiPost", admin: true do 
    before do
      init_setup editor
      @listing = create :listing, seller_id: user.id, status: 'active', pixan_id: pixter.id
      @pixi_post = user.pixi_posts.create attributes_for(:pixi_post)
      visit edit_pixi_post_path(@pixi_post)
    end

    it "does not set completed date", js: true do
      expect{
        fill_in 'cmp-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'cmp-tm')
	set_pixan
        click_button commit; sleep 2
      }.to change(PixiPost,:count).by(0)
      expect(page).to have_content "Must have a pixi"
    end

    it "sets completed date", js: true do
      expect{
        fill_in 'appt-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'appt-tm')
        fill_in 'cmp-dt', with: Date.tomorrow().strftime('%m/%d/%Y')
        select('1:00 PM', :from => 'cmp-tm')
	set_pixan
	set_pixi
        # select(@listing.title, :from => 'listing_tokens')
	# fill_token_input 'listing_tokens', with: @listing.title
        click_button commit; sleep 2
      }.to change(PixiPost,:count).by(0)

      expect(page).to have_content 'PixiPost Request'
      expect(page).to have_content 'Completed Date'
      expect(page).to have_content 'Completed Time'
    end
  end

  describe "Editor views a PixiPost", admin: true do 
    before do
      init_setup editor
      @pixan = create :pixi_user, user_type_code: 'PX'
      @listing = create :listing, seller_id: user.id, pixan_id: @pixan.id
      @pixi_post = user.pixi_posts.create attributes_for(:pixi_post, description: 'tire rims')
      @scheduled = user.pixi_posts.create attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days,
        appt_time: Time.now+3.days, description: 'xbox 360'
      @completed = user.pixi_posts.create attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days, 
        appt_time: Time.now+3.days, completed_date: Time.now+3.days, pixi_id: @listing.pixi_id, description: 'rocking chair'
      visit pixi_posts_path(status: 'active') 
    end

    it 'show content' do
      expect(page).to have_link("#{@pixi_post.id}", href: pixi_post_path(@pixi_post))
      expect(page).to have_selector('title', text: 'PixiPosts')
      expect(page).not_to have_selector('title', text: 'My PixiPosts')
      expect(page).not_to have_link "Submitted", href: seller_pixi_posts_path(status: 'active')
      expect(page).not_to have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      expect(page).not_to have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      expect(page).to have_link "Submitted", href: pixi_posts_path(status: 'active')
      expect(page).to have_link "Scheduled", href: pixi_posts_path(status: 'scheduled')
      expect(page).to have_link "Completed", href: pixi_posts_path(status: 'completed')
      expect(page).to have_content "PixiPost"
      expect(page).to have_content "Seller Name" 
      expect(page).not_to have_content "Pixter Name" 
      expect(page).to have_content "Preferred Date"
      expect(page).to have_content "Preferred Time"
      expect(page).not_to have_content "Scheduled Date"
      expect(page).not_to have_content "Scheduled Time"
      expect(page).not_to have_content "Completed Date"
      expect(page).not_to have_content "Completed Time"
    end

    it 'show scheduled content' do
      visit pixi_posts_path(status: 'scheduled')
      expect(page).to have_content "Seller Name" 
      expect(page).not_to have_content "Pixter Name" 
      expect(page).not_to have_content "Preferred Date"
      expect(page).not_to have_content "Preferred Time"
      expect(page).to have_content "Scheduled Date"
      expect(page).to have_content "Scheduled Time"
      expect(page).not_to have_content "Completed Date"
      expect(page).not_to have_content "Completed Time"
      expect(page).not_to have_content 'No posts found'
    end

    it 'show completed content' do
      visit pixi_posts_path(status: 'completed')
      expect(page).to have_content "Seller Name" 
      expect(page).not_to have_content "Pixter Name" 
      expect(page).not_to have_content "Preferred Date"
      expect(page).not_to have_content "Preferred Time"
      expect(page).not_to have_content "Scheduled Date"
      expect(page).not_to have_content "Scheduled Time"
      expect(page).to have_content "Completed Date"
      expect(page).to have_content "Completed Time"
      expect(page).not_to have_content 'No posts found'
    end

    it "clicks to open a pixipost" do
      visit pixi_post_path(@pixi_post)
      expect(page).to have_content "PixiPosts"
      expect(page).to have_content "PixiPost Request"
      expect(page).to have_content @pixi_post.description
      expect(page).to have_content user.name
      expect(page).to have_link 'Edit', href: edit_pixi_post_path(@pixi_post) 
      expect(page).not_to have_link 'Remove', href: pixi_post_path(@pixi_post) 
      expect(page).not_to have_link 'Reschedule', href: reschedule_pixi_post_path(@pixi_post) 
      # page.should have_selector('#rm-btn', visible: false) 
      expect(page).to have_link 'Done', href: pixi_posts_path(status: 'active') 
    end

    it "clicks to open a scheduled pixipost" do
      visit pixi_post_path(@scheduled)
      expect(page).to have_content "PixiPost Request"
      expect(page).to have_link 'Edit', href: edit_pixi_post_path(@scheduled) 
      expect(page).not_to have_link 'Reschedule', href: reschedule_pixi_post_path(@scheduled) 
      expect(page).not_to have_link 'Remove', href: pixi_post_path(@scheduled) 
      expect(page).to have_link 'Done', href: pixi_posts_path(status: 'active') 
      expect(page).to have_content @scheduled.description
      expect(page).to have_content user.name
    end

    it "clicks to open a completed pixipost" do
      visit pixi_post_path(@completed)
      expect(page).to have_content "PixiPost Request"
      expect(page).to have_link 'Edit', href: edit_pixi_post_path(@completed) 
      expect(page).not_to have_link 'Reschedule', href: reschedule_pixi_post_path(@completed) 
      expect(page).not_to have_link 'Remove', href: pixi_post_path(@completed) 
      expect(page).to have_link 'Done', href: pixi_posts_path(status: 'active') 
      expect(page).to have_content @completed.description
      expect(page).to have_content user.name
    end
  end

  describe "Editor cancels a PixiPost", admin: true do 
    before do
      init_setup editor
      @pixi_post = user.pixi_posts.create attributes_for(:pixi_post)
      visit edit_pixi_post_path(@pixi_post) 
    end

    it "cancels pixipost edit", js: true do
      click_cancel_ok; sleep 2
      expect(page).to have_content "PixiPosts" 
    end

    it "cancels edit of pixipost", js: true do
      click_cancel_cancel
      expect(page).to have_content "Edit PixiPost" 
    end
  end

  describe "Pixter views a PixiPost", pixter: true do 
    before do
      init_setup pixter
      @pixan = create :pixi_user, user_type_code: 'PX'
      @listing = create :listing, seller_id: user.id, pixan_id: @pixan.id
      @pixi_post = user.pixi_posts.create attributes_for(:pixi_post, description: 'tire rims')
      @scheduled = user.pixi_posts.create attributes_for :pixi_post, pixan_id: @user.id, appt_date: Time.now+3.days,
        appt_time: Time.now+3.days, description: 'xbox 360'
      @completed = user.pixi_posts.create attributes_for :pixi_post, pixan_id: @user.id, appt_date: Time.now+3.days,
        appt_time: Time.now+3.days, completed_date: Time.now + 3.days, pixi_id: @listing.pixi_id, description: 'rocking chair',
        status: 'completed'
      visit pixter_pixi_posts_path(status: 'scheduled')
    end

    it 'show content', js: true do
      expect(page).not_to have_content 'No posts found'
      # page.should have_selector('title', text: 'PixiPosts')
      expect(page).not_to have_selector('title', text: 'My PixiPosts')
      expect(page).not_to have_link "Submitted", href: pixter_pixi_posts_path(status: 'active')
      expect(page).to have_link "Scheduled", href: pixter_pixi_posts_path(status: 'scheduled')
      expect(page).to have_link "Completed", href: pixter_pixi_posts_path(status: 'completed')
      expect(page).to have_link "Pixter Report", href: pixter_report_pixi_posts_path
      expect(page).not_to have_link "Submitted", href: seller_pixi_posts_path(status: 'active')
      expect(page).not_to have_link "Scheduled", href: seller_pixi_posts_path(status: 'scheduled')
      expect(page).not_to have_link "Completed", href: seller_pixi_posts_path(status: 'completed')
      expect(page).not_to have_link "Submitted", href: pixi_posts_path(status: 'active')
      expect(page).not_to have_link "Scheduled", href: pixi_posts_path(status: 'scheduled')
      expect(page).not_to have_link "Completed", href: pixi_posts_path(status: 'completed')
      expect(page).to have_content "PixiPost"
      expect(page).to have_link("#{@scheduled.id}", href: pixi_post_path(@scheduled))
      expect(page).to have_content "Seller Name" 
      expect(page).not_to have_content "Pixter Name" 
      expect(page).not_to have_content "Preferred Date"
      expect(page).not_to have_content "Preferred Time"
      expect(page).to have_content "Scheduled Date"
      expect(page).to have_content "Scheduled Time"
      expect(page).not_to have_content "Completed Date"
      expect(page).not_to have_content "Completed Time"
    end

    it 'show completed content' do
      visit pixter_pixi_posts_path(status: 'completed')
      expect(page).not_to have_content 'No posts found'
      expect(page).to have_content "Seller Name" 
      expect(page).not_to have_content "Pixter Name" 
      expect(page).not_to have_content "Preferred Date"
      expect(page).not_to have_content "Preferred Time"
      expect(page).not_to have_content "Scheduled Date"
      expect(page).not_to have_content "Scheduled Time"
      expect(page).to have_content "Completed Date"
      expect(page).to have_content "Completed Time"
    end

    it "clicks to open a scheduled pixipost" do
      visit pixi_post_path(@scheduled)
      expect(page).to have_content "PixiPost Request"
      expect(page).to have_link "Scheduled", href: pixter_pixi_posts_path(status: 'scheduled')
      expect(page).to have_link "Completed", href: pixter_pixi_posts_path(status: 'completed')
      expect(page).not_to have_link "Submitted", href: pixi_posts_path(status: 'active')
      expect(page).not_to have_link "Scheduled", href: pixi_posts_path(status: 'scheduled')
      expect(page).not_to have_link "Completed", href: pixi_posts_path(status: 'completed')
      expect(page).not_to have_link 'Edit', href: edit_pixi_post_path(@scheduled) 
      expect(page).not_to have_link 'Reschedule', href: reschedule_pixi_post_path(@scheduled) 
      expect(page).not_to have_link 'Remove', href: pixi_post_path(@scheduled) 
      expect(page).to have_link 'Done', href: pixter_pixi_posts_path(status: 'scheduled') 
      expect(page).to have_content @scheduled.description
      expect(page).to have_content user.name
    end

    it "clicks to open a completed pixipost" do
      visit pixi_post_path(@completed)
      expect(page).to have_content "PixiPost Request"
      expect(page).to have_link "Scheduled", href: pixter_pixi_posts_path(status: 'scheduled')
      expect(page).to have_link "Completed", href: pixter_pixi_posts_path(status: 'completed')
      expect(page).not_to have_link "Submitted", href: pixi_posts_path(status: 'active')
      expect(page).not_to have_link "Scheduled", href: pixi_posts_path(status: 'scheduled')
      expect(page).not_to have_link "Completed", href: pixi_posts_path(status: 'completed')
      expect(page).not_to have_link 'Edit', href: edit_pixi_post_path(@completed) 
      expect(page).not_to have_link 'Reschedule', href: reschedule_pixi_post_path(@completed) 
      expect(page).not_to have_link 'Remove', href: pixi_post_path(@completed) 
      expect(page).to have_link 'Done', href: pixter_pixi_posts_path(status: 'scheduled') 
      expect(page).to have_content @completed.description
      expect(page).to have_content user.name
    end
  end

  describe "pagination", admin: true do
    before do
      init_setup admin
      @listing_completed = create :listing, seller_id: user.id, pixan_id: pixter.id
      30.times {
        user.pixi_posts.create attributes_for :pixi_post, pixan_id: pixter.id, appt_date: Time.now,
            appt_time: Time.now, completed_date: Time.now, pixi_id: @listing_completed.pixi_id, description: 'rocking chair',
                status: 'completed'
      }
      visit pixter_report_pixi_posts_path
    end

    it "should paginate", js: true do
      expect(page).not_to have_content 'No posts found'
      expect (PixiPost.where(user_id: user.id).count == 30)
    end

    it { is_expected.to have_selector('div.pagination') }

    it "should list each pixipost" do
      PixiPost.paginate(page: 1).each do |pixipost|
        expect(page).to have_selector('li', text: PixiPost.sale_date(pixipost).to_s)
      end
    end
  end
end
