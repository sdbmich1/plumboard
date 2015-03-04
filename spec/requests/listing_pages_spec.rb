require 'spec_helper'

feature "Listings" do
  subject { page }
  
  let(:user) { create(:contact_user) }
  let(:pixter) { create :pixter, user_type_code: 'PT', confirmed_at: Time.now }
  let(:admin) { create :admin, confirmed_at: Time.now }
  let(:site) { create :site }
  let(:site_contact) { site.contacts.create attributes_for(:contact) }
  let(:condition_type) { create :condition_type, code: 'UG', description: 'Used - Good', hide: 'no', status: 'active' }
  let(:temp_listing) { create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: user.id ) }
  let(:listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id,
    site_id: site.id, quantity: 1, condition_type_code: condition_type.code) }
  let(:pixi_post_listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, 
    pixan_id: pixter.id, site_id: site.id) }
  let(:submit) { "Want" }

  def set_site_id val=@site.id
    page.execute_script %Q{ $('#site_id').val("#{val}") }
  end
  
  def pixi_edit_access listing
    page.should have_content listing.category_name
    page.should have_content "Quantity: #{(listing.amt_left)}"
    page.should have_content "Posted By: #{listing.seller_name}"
    page.should have_link 'Want'
    page.should have_link 'Ask'
    page.should have_link 'Cool'
    page.should_not have_link 'Uncool'
    page.should have_link 'Save'
    page.should_not have_link 'Unsave'
    page.should have_selector('#fb-link')
    page.should have_selector('#tw-link')
    page.should have_selector('#pin-link')
    page.should have_button 'Remove'
    page.should have_link 'Edit', href: edit_temp_listing_path(listing)
  end

  describe "Non-signed in user" do
    before(:each) do
      visit listing_path(pixi_post_listing) 
    end
     
    it "does not contact a seller", js: true do
      expect{
          click_link 'Want'
      }.not_to change(Post,:count).by(1)
      page.should have_content 'Sign in'
    end
    it "does not ask a question", js: true do
      expect{
          click_link 'Ask'
      }.not_to change(Post,:count).by(1)
      page.should have_content 'Sign in'
    end

    it "does not add Cool", js: true do
      expect{
          page.find('#cool-btn').click
          page.should_not have_link 'Uncool'
      }.not_to change(PixiLike,:count).by(1)
      page.should have_content 'Sign in'
    end

    it "does not add Save", js: true do
      expect{
          page.find('#save-btn').click
          page.should_not have_link 'Unsave'
      }.not_to change(SavedListing,:count).by(1)
      page.should have_content 'Sign in'
    end

    it "does not add comment", js: true do
      expect{
          page.find('#add-comment-btn').click
      }.not_to change(Comment,:count).by(1)
      page.should have_content 'Sign in'
      sleep 2;
      user_login user
      page.should have_content pixi_post_listing.nice_title
    end
  end

  describe "Contact Owner" do 
    before(:each) do
      pixi_user = create(:pixi_user)
      init_setup pixi_user
      visit listing_path(pixi_post_listing) 
    end

    it "Contacts a seller", js: true do
      expect{
          page.should have_link 'Want'
          page.should have_link 'Ask'
          page.should have_link 'Cool'
          click_link 'Want'
	        click_button 'Send'
	        sleep 5
          page.should_not have_link 'Want'
          page.should have_content 'Want'
          page.should have_content 'Successfully sent message to seller'
      }.to change(Post,:count).by(1)

      expect(Conversation.count).to eql(1)
      expect(PixiWant.first.quantity).to eql(1)
      expect{
      	  fill_in 'comment_content', with: "Great pixi. I highly recommend it.\n" 
	        sleep 3
      }.to change(Comment,:count).by(1)

      page.should have_content "Comments (#{pixi_post_listing.comments.size})"
      page.should have_content "Great pixi. I highly recommend it." 
      page.should have_content @user.name 
      expect(page).not_to have_field('#comment_content', with: 'Great pixi')
    end
     
    it "does not contact a seller", js: true do
      expect{
          page.should have_link 'Want'
          click_link 'Want'
          sleep 3
	        click_link 'Close'
          page.should_not have_content 'Successfully sent message to seller'
      }.not_to change(Post,:count).by(1)
    end

    it "clicks on Cool", js: true do
      expect{
          page.find('#cool-btn').click
	        sleep 3
          page.should have_link 'Uncool'
          page.should_not have_link 'Cool'
      }.to change(PixiLike,:count).by(1)
      page.should have_content listing.nice_title
      page.should have_content "(#{listing.liked_count})"
    end

    it "clicks on Save", js: true do
      expect{
          page.find('#save-btn').click
	  sleep 3
          page.should have_link 'Unsave'
      }.to change(SavedListing,:count).by(1)

      page.should have_content listing.nice_title
    end
  end

  describe "View Pixi w/ buyer flags set" do 
    before(:each) do
      pixi_user = create(:pixi_user) 
      init_setup pixi_user
      @user.pixi_likes.create attributes_for :pixi_like, pixi_id: listing.pixi_id
      @user.pixi_wants.create attributes_for :pixi_want, pixi_id: listing.pixi_id
      @user.saved_listings.create attributes_for :saved_listing, pixi_id: listing.pixi_id
      @user.posts.create attributes_for :post, pixi_id: listing.pixi_id, recipient_id: user.id
      visit listing_path(listing) 
    end

    it "views pixi page" do
      expect(listing.user_wanted?(@user)).not_to be_nil
      page.should have_content 'Want'
      page.should_not have_link 'Want', href: '#'
      page.find_link('Uncool').visible?
      page.should_not have_link 'Cool'
      page.should have_link 'Unsave'
    end

    it "clicks on Uncool", js: true do
      expect{
          page.find('#cool-btn').click
	  sleep 3
          page.should_not have_link 'Uncool'
          page.should have_link 'Cool'
      }.to change(PixiLike,:count).by(-1)
      page.should have_content listing.nice_title
      page.should have_content "(#{listing.liked_count})"
    end

    it "clicks on Unsave", js: true do
      expect{
          page.find('#save-btn').click
	  sleep 3
          page.should have_link 'Save'
      }.to change(SavedListing,:count).by(-1)
      page.should have_content listing.nice_title
    end
  end

  describe "View Event Pixi", process: true do 
    let(:event_type) { create :event_type }
    let(:category) { create :category, name: 'Event', category_type_code: 'event' }
    let(:event_listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id, 
      category_id: category.id, event_start_date: Date.tomorrow, event_end_date: Date.tomorrow, event_start_time: Time.now+2.hours, 
      event_end_time: Time.now+3.hours, event_type_code: event_type.code, quantity: 1 ) }

    before(:each) do
      pixi_user = create(:pixi_user) 
      init_setup pixi_user
      visit listing_path(event_listing) 
    end
     
    it "views pixi page" do
      page.should have_content event_listing.nice_title
      page.should have_content event_listing.seller_name
      page.should have_content "Start Date: #{short_date(event_listing.event_start_date)}"
      page.should have_content "End Date: #{short_date(event_listing.event_end_date)}"
      #page.should have_content "Start Time: #{short_time(event_listing.event_start_time)}"
      #page.should have_content "End Time: #{short_time(event_listing.event_end_time)}"
      page.should have_content "Event Type: #{event_listing.event_type_descr}"
      page.should_not have_content "Compensation: #{(event_listing.compensation)}"
      page.should_not have_content "Condition: #{(event_listing.condition)}"
      page.should have_content "Quantity: #{(event_listing.amt_left)}"
    end
  end

  describe "View Sold Pixi", process: true do 
    let(:sold_listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, 
      site_id: site.id, status: 'sold', quantity: 1, condition_type_code: condition_type.code) }
    before(:each) do
      init_setup user
      visit listing_path(sold_listing) 
    end

    it "views pixi page" do
      page.should have_content "Posted By: #{sold_listing.seller_name}"
      page.should_not have_selector('#contact_content')
      page.should_not have_selector('#comment_content')
      page.should_not have_selector('#want-btn')
      page.should_not have_selector('#ask-btn')
      page.should_not have_selector('#send-want-btn')
      page.should_not have_selector('#cool-btn')
      page.should_not have_selector('#save-btn')
      page.should_not have_selector('#fb-link')
      page.should_not have_selector('#tw-link')
      page.should_not have_selector('#pin-link')
      page.should_not have_link 'Follow', href: '#'
      page.should_not have_content "Quantity: #{sold_listing.amt_left}"
      page.should have_content "Condition: #{sold_listing.condition}"
      page.should have_content "Want (#{sold_listing.wanted_count})"
      page.should have_content "Cool (#{sold_listing.liked_count})"
      page.should have_content "Saved (#{sold_listing.saved_count})"
      page.should have_content "Comments (#{sold_listing.comments.size})"
      page.should have_content "Ask (#{sold_listing.asked_count})"
      page.should_not have_link 'Cancel', href: root_path
      page.should_not have_button 'Remove'
      page.should_not have_link 'Edit', href: edit_temp_listing_path(sold_listing)
    end
  end

  describe "View Compensation Pixi", process: true do 
    let(:category) { create :category, name: 'Gigs', category_type_code: 'employment' }
    let(:job_type) { create :job_type }
    let(:job_listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, quantity: nil,
      category_id: category.id, job_type_code: job_type.code, compensation: 'Salary + Equity', price: nil) }

    before(:each) do
      pixi_user = create(:pixi_user) 
      init_setup pixi_user
      visit listing_path(job_listing) 
    end
     
    it "views pixi page" do
      page.should_not have_content "Start Date: #{short_date(job_listing.event_start_date)}"
      page.should_not have_content "End Date: #{short_date(job_listing.event_end_date)}"
      page.should_not have_content "Start Time: #{short_time(job_listing.event_start_time)}"
      page.should_not have_content "End Time: #{short_time(job_listing.event_end_time)}"
      page.should_not have_content "Price: #{(job_listing.price)}"
      page.should_not have_content "Event Type: #{job_listing.event_type_descr}"
      page.should_not have_content "Condition: #{(job_listing.condition)}"
      page.should_not have_content "Quantity: #{(job_listing.amt_left)}"
      page.should have_content "Job Type: #{(job_listing.job_type_name)}"
      page.should have_content "Compensation: #{(job_listing.compensation)}"
    end
  end

  describe "Owner-viewed Pixi", process: true do 
    before(:each) do
      init_setup user
      visit listing_path(listing) 
    end

    it "views pixi page" do
      page.should have_content "Posted By: #{listing.seller_name}"
      page.should_not have_selector('#contact_content')
      page.should_not have_selector('#comment_content')
      page.should_not have_selector('#want-btn')
      page.should_not have_selector('#send-want-btn')
      page.should_not have_selector('#cool-btn')
      page.should_not have_selector('#save-btn')
      page.should_not have_selector('#ask-btn')
      page.should have_selector('#fb-link')
      page.should have_selector('#tw-link')
      page.should have_selector('#pin-link')
      page.should_not have_link 'Follow', href: '#'
      page.should have_content "Want (#{listing.wanted_count})"
      page.should have_content "Ask (#{listing.asked_count})"
      page.should have_content "Cool (#{listing.liked_count})"
      page.should have_content "Saved (#{listing.saved_count})"
      page.should have_content "Comments (#{listing.comments.size})"
      page.should have_content "Quantity: #{(listing.amt_left)}"
      page.should have_content "Condition: #{(listing.condition)}"
      page.should_not have_link 'Cancel', href: root_path
      page.should have_button 'Remove'
      page.should have_link 'Changed Mind', href: listing_path(listing, reason: 'Changed Mind')
      page.should have_link 'Donated Item', href: listing_path(listing, reason: 'Donated Item')
      page.should have_link 'Gave Away Item', href: listing_path(listing, reason: 'Gave Away Item')
      page.should have_link 'Sold Item', href: listing_path(listing, reason: 'Sold Item')
      page.should have_link 'Edit', href: edit_temp_listing_path(listing)
    end
  end

  describe "Pixter-viewed Pixi" do 
    before(:each) do
      init_setup pixter
      visit listing_path(pixi_post_listing) 
    end

    it "views pixi page" do
      pixi_edit_access pixi_post_listing
    end
  end

  describe "Admin-viewed Pixi", process: true do 
    before(:each) do
      init_setup admin
      visit listing_path(listing) 
    end

    it "views pixi page" do
      pixi_edit_access listing
    end
  end

  describe "Add Comments" do 
    before(:each) do
      pixi_user = create(:pixi_user) 
      init_setup pixi_user
      visit listing_path(listing) 
    end

    it "views pixi page" do
      page.should have_content "No comments found."
      page.should have_content "Comments (#{listing.comments.size})"
    end
     
    it "adds a comment", js: true do
      expect{
      	  fill_in 'comment_content', with: "Great pixi. I highly recommend it.\n" 
	  sleep 3
      }.to change(Comment,:count).by(1)

      page.should have_content "Comments (#{listing.comments.size})"
      page.should have_content "Great pixi. I highly recommend it." 
      page.should have_content @user.name 
      expect(page).not_to have_field('#comment_content', with: 'Great pixi')
    end
     
    it "does not add a comment", js: true do
      expect{
	  fill_in 'comment_content', with: "\n"
      }.not_to change(Comment,:count).by(1)
    end
  end

  describe "pagination" do
    before(:each) do
      pixi_user = create(:pixi_user) 
      init_setup pixi_user
      10.times { listing.comments.create attributes_for(:comment, user_id: pixi_user.id) } 
      visit listing_path(listing) 
    end

    it { should have_selector('div.pagination') }

    it "should list each comment" do
      listing.comments.paginate(page: 1).each do |comment|
        page.should have_selector('li', text: comment.summary)
      end
    end
  end

  describe "Check Pixis" do 
    before(:each) do
      editor = create :editor, email: 'jsnow@pixitext.com', confirmed_at: Time.now 
      @listing = create :listing, seller_id: editor.id
      @pixi_want = editor.pixi_wants.create attributes_for :pixi_want, pixi_id: @listing.pixi_id
      @pixi_like = editor.pixi_likes.create attributes_for :pixi_like, pixi_id: @listing.pixi_id
      init_setup editor
    end

    describe "Review Pixis" do 
      before { visit listing_path(@listing) }

      it "Deletes a pixi" do
        expect {
          click_link 'Sold Item'; sleep 2
          page.should_not have_content @listing.title 
          page.should have_content "Pixis" 
        }.to change(Listing, :count).by(0)
	expect(@listing.reload.status).to eq('removed')
      end

      describe "Edits active pixi" do
        it "adds a pixi pic" do
          click_link 'Edit'; sleep 3
          page.should have_content("Build Your Pixi") 
          page.should have_selector('#build-pixi-btn')
          expect{
	    fill_in 'Title', with: 'Rhodes Bass Guitar'
            attach_file('photo', Rails.root.join("spec", "fixtures", "photo0.jpg"))
            page.find('#build-pixi-btn').click
            page.should have_content 'Review Your Pixi'
            click_link 'Done!'
            page.should have_content 'Rhodes Bass Guitar'
            visit pending_listing_path(@listing) 
            page.should have_content 'Rhodes Bass Guitar'
            page.should have_button('Deny')
            page.should have_link 'Approve', href: approve_pending_listing_path(@listing)
            click_link 'Approve'; sleep 2;
	    visit listing_path(@listing)
            page.should have_content 'Rhodes Bass Guitar'
            @listing.wanted_count.should eq(1)
            @listing.liked_count.should eq(1)
            @listing.pictures.count.should eq(2)
            Listing.where(seller_id: @user.id).count.should eq(1)
            # TempListing.where(pixi_id: @listing.pixi_id).count.should eq(0)
            # TempListing.where("title like 'Rhodes%'").count.should eq(0)
            Listing.where("title like 'Rhodes%'").count.should eq(1)
            Listing.where("title like 'Acoustic%'").count.should eq(0)
          }.to change(Listing,:count).by(0)
        end
      end
    end

    describe "GET /category" do  
      let(:category) { create :category }
      let(:site) { create :site }
      let(:listings) { 10.times { create(:listing, seller_id: @user.id, category_id: category.id, site_id: site.id) } }

      before(:each) do
        create(:listing, title: "Guitar", seller_id: @user.id, site_id: site.id, category_id: category.id) 
        visit category_listings_path(cid: category.id, loc: site.id) 
      end
      
      it "views pixi category page" do
        page.should have_content('Pixis')
        page.should have_content 'Guitar'
        page.should_not have_content 'No pixis found'
      end

      it "does not show status type" do
        page.should_not have_content "Status"
      end
    end  

    describe "GET /local" do  
      let(:category) { create :category }
      let(:site) { create :site }
      let(:listings) { 10.times { create(:listing, seller_id: @user.id, category_id: category.id, site_id: site.id) } }

      before(:each) do
        create(:listing, title: "Guitar", seller_id: @user.id, site_id: site.id, category_id: category.id) 
        visit local_listings_path(cid: category.id, loc: site.id) 
      end
      
      it "views pixi category page" do
        page.should have_content('Pixis')
        page.should have_content 'Guitar'
        page.should_not have_content 'No pixis found'
      end

      it "does not show status type" do
        page.should_not have_content "Status"
      end
    end  

    describe "GET /listings" do  
      let(:listings) { 30.times { create(:listing, seller_id: @user.id) } }

      before(:each) do
        add_region
        @site = create :site, name: 'Detroit', org_type: 'city'
	      @site.contacts.create attributes_for :contact, address: '1611 Tyler', city: 'Detroit', state: 'MI', zip: '48238'
        @site3 = create :site, name: 'Pixi Tech', org_type: 'school'
	      @site3.contacts.create attributes_for :contact, address: '14018 Prevost', city: 'Detroit', state: 'MI', zip: '48227'
	      @category = create :category, name: 'Music'
	      @category5 = create :category, name: 'Electronics'
        create(:listing, title: "HP Printer J4580", description: "printer", seller_id: @user.id, site_id: @site.id, 
	      category_id: @category5.id) 
	      @category1 = create :category, name: 'Jobs'
	      @category2 = create :category, name: 'Automotive'
	      @category3 = create :category, name: 'Furniture'
	      @category4 = create :category, name: 'Books'
        @listing = create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, category_id: @category.id, site_id: @site3.id) 
        @listing1 = create(:listing, title: "Intern", description: "Unpaid job", seller_id: @user.id, category_id: @category1.id, 
	  site_id: @site3.id) 
        @listing2 = create(:listing, title: "Buick Regal", description: "used car", seller_id: @user.id, category_id: @category2.id) 
        @listing3 = create(:listing, title: "Sofa", description: "used couch", seller_id: @user.id, category_id: @category3.id) 
        @listing4 = create(:listing, title: "Calc 201", description: "text book", seller_id: @user.id, category_id: @category4.id) 
        visit local_listings_path(loc: @site2.id) 
      end
      
      it "views pixis page" do
        visit local_listings_path(loc: @site1.id) 
        page.should have_link 'Recent'
        page.should have_content('Pixis')
        page.should_not have_content 'No pixis found'
      end
      
      it "scrolls listings", js: true do 
        page.execute_script "window.scrollBy(0,1000)"
      end

      it "searches for a listing", js: true do
        fill_in 'search', with: 'guitar'
	      click_on 'submit-btn'
        page.should_not have_content 'HP Printer J4580'
      end

      it "selects a site", js: true do
        fill_autocomplete('site_name', with: 'pixi')
	      set_site_id @site3.id; sleep 2
        page.should have_content @listing1.title
        page.should have_content @pixi.title
        page.should have_content @site3.name
      end

      it "selects categories", js: true do
        fill_autocomplete('site_name', with: 'pixi')
	      set_site_id @site3.id; sleep 2
        select('Music', :from => 'category_id'); sleep 2
        page.should have_content @category.name_title
        page.should_not have_content @listing1.title
        page.should have_content 'Guitar'
      end
    end

    describe "Repost button" do
      before do
        @active_listing = create(:listing, seller_id: @user.id, title: 'Bookshelf')
        @active_listing.status = 'active'
        @active_listing.save!
        @sold_listing = create(:listing, seller_id: @user.id, title: 'Leather Briefcase') 
        @sold_listing.status = 'sold'
        @sold_listing.save!
        @expired_listing = create(:listing, seller_id: @user.id, title: 'TV')
        @expired_listing.status = 'expired'
        @expired_listing.save!
        @removed_listing = create(:listing, seller_id: @user.id, title: 'Suede Jacket') 
        @removed_listing.status = 'removed'
        @removed_listing.save!
      end

      it "should appear for expired pixi" do
        visit listing_path(@expired_listing)
        page.should have_link 'Repost!', href: repost_listing_path(@expired_listing)
      end

      it "should appear for sold pixi" do
        visit listing_path(@sold_listing)
        page.should have_link 'Repost!', href: repost_listing_path(@sold_listing)
        page.should_not have_link 'Edit', href: edit_temp_listing_path(listing)
        page.should_not have_button 'Remove'
      end

      it "should appear for removed pixi" do
        visit listing_path(@removed_listing)
        page.should_not have_link 'Edit', href: edit_temp_listing_path(listing)
        page.should have_link 'Repost!', href: repost_listing_path(@removed_listing)
        page.should_not have_button 'Remove'
      end

      it "should not appear for pixi with other status" do
        visit listing_path(@active_listing)
        page.should_not have_link 'Repost!', href: repost_listing_path(@active_listing)
      end

      it "reposts an expired pixi", js: true do
        visit listing_path(@expired_listing)
        page.should_not have_link 'Edit', href: edit_temp_listing_path(listing)
        page.should_not have_button 'Remove'
        click_link 'Repost!'
        page.should have_content 'Pixis'    # should go back to home page
        visit listing_path(@expired_listing)
        page.should_not have_link 'Repost!', href: repost_listing_path(@expired_listing)   # pixi shouldn't be expired anymore
      end

      it "reposts a sold pixi", js: true do
        visit listing_path(@sold_listing)
        page.should_not have_link 'Edit', href: edit_temp_listing_path(listing)
        page.should_not have_button 'Remove'
	expect{
          click_link 'Repost!'
          page.should have_content 'Pixis'    # should go back to home page
        }.to change(Listing.active,:count).by(1)
      end

      it "reposts a removed pixi", js: true do
        visit listing_path(@removed_listing)
        page.should_not have_link 'Edit', href: edit_temp_listing_path(listing)
        page.should_not have_button 'Remove'
	expect{
          click_link 'Repost!'
          page.should have_content 'Pixis'    # should go back to home page
        }.to change(Listing.active,:count).by(1)
      end
    end
  end
end
