require 'spec_helper'

feature "Listings" do
  subject { page }
  
  let(:user) { create(:contact_user) }
  let(:pixter) { create :pixter, user_type_code: 'PT', confirmed_at: Time.now }
  let(:admin) { create :admin, confirmed_at: Time.now }
  let(:category) { create :category }
  let(:site) { create :site }
  let(:site_contact) { site.contacts.create attributes_for(:contact) }
  let(:condition_type) { create :condition_type, code: 'UG', description: 'Used - Good', hide: 'no', status: 'active' }
  let(:temp_listing) { create(:temp_listing, title: "Guitar", description: "Lessons", seller_id: user.id ) }
  let(:listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id,
    site_id: site.id, quantity: 1, condition_type_code: condition_type.code) }
  let(:pixi_post_listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, quantity: 1,
    pixan_id: pixter.id, site_id: site.id) }
  let(:post_listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, quantity: 2, site_id: site.id) }
  let(:submit) { "Want" }

  def set_site_id val=@site.id
    page.execute_script %Q{ $('#site_id').val("#{val}") }
  end

  def add_business_sellers
    @seller1 =  create(:contact_user, user_type_code: 'BUS', business_name: 'Rhythm Music') 
    @seller2 =  create(:contact_user, user_type_code: 'BUS', business_name: 'Star Music')   
    @seller3 =  create(:contact_user, user_type_code: 'BUS', business_name: 'Joy Music')   
    @seller4 =  create(:contact_user, user_type_code: 'BUS', business_name: 'Merry Music')   
    @seller5 =  create(:contact_user, user_type_code: 'BUS', business_name: 'Geary Music')   
  end
  
  def pixi_edit_access listing
    expect(page).to have_content listing.category_name
    expect(page).to have_content "Amount Left: #{(listing.amt_left)}"
    expect(page).to have_content "#{listing.seller_name}"
    expect(page).to have_link 'Want'
    expect(page).to have_link 'Ask'
    expect(page).to have_link 'Cool'
    expect(page).not_to have_link 'Uncool'
    expect(page).to have_link 'Save'
    expect(page).not_to have_link 'Unsave'
    expect(page).to have_selector('#fb-link')
    expect(page).to have_selector('#tw-link')
    expect(page).to have_selector('#pin-link')
    expect(page).to have_button 'Remove'
    expect(page).to have_link 'Edit', href: edit_temp_listing_path(listing)
  end

  describe "Non-signed in user", contact: true do
    before(:each) do
      visit listing_path(pixi_post_listing) 
    end
     
    it "does not contact a seller", js: true do
      expect{
          click_link 'Want'
      }.not_to change(Post,:count)
      expect(page).to have_content 'Sign in'
    end

    it "does not ask a question", js: true do
      expect{
          click_link 'Ask'
      }.not_to change(Post,:count)
      expect(page).to have_content 'Sign in'
    end

    it "does not add Cool", js: true do
      expect{
          page.find('#cool-btn').click
          expect(page).not_to have_link 'Uncool'
      }.not_to change(PixiLike,:count)
      expect(page).to have_content 'Sign in'
    end

    it "does not add Save", js: true do
      expect{
          page.find('#save-btn').click
          expect(page).not_to have_link 'Unsave'
      }.not_to change(SavedListing,:count)
      expect(page).to have_content 'Sign in'
    end

    it "does not add comment", js: true do
      expect{
          page.find('#add-comment-btn').click
      }.not_to change(Comment,:count)
      expect(page).to have_content 'Sign in'
      sleep 2;
      user_login user
      expect(page).to have_content pixi_post_listing.nice_title(false)
    end
  end

    def want_request sFlg=true, qty=1
      expect{
          expect(page).to have_link 'Want'
          expect(page).to have_link 'Ask'
          expect(page).to have_link 'Cool'
          click_link 'Want'; sleep 2
          check_page_selectors ['#px-qty'], true, sFlg
          if qty > 1
            select("#{qty}", :from => "px-qty")
          end
          click_link 'Send'
          sleep 5
          expect(page).not_to have_link 'Want'
          expect(page).to have_content 'Want'
          expect(page).to have_content 'Successfully sent message to seller'
      }.to change(Post,:count).by(1)
      expect(Conversation.count).to eql(1)
      expect(PixiWant.first.quantity).to eql(qty)
    end

  describe "Contact Owner", seller: true do 
    before(:each) do
      pixi_user = create(:pixi_user)
      init_setup pixi_user
      visit listing_path(pixi_post_listing) 
    end

    context "Wants a pixi", js: true do
      it_should_behave_like 'want_request'
    end

    context "Contacts a seller", js: true do
      it 'asks a question' do
        expect{
          expect(page).to have_link 'Ask'
          expect(page).to have_link 'Cool'
          click_link 'Ask'
          sleep 3
          fill_in 'ask_content', with: "Is this a new item?\n" 
          click_button 'Send'
          sleep 5
          expect(page).to have_content 'Successfully sent message to seller'
        }.to change(Post,:count).by(1)

        it_should_behave_like 'want_request'

        expect{
          page.find('#comment-tab').click
      	  fill_in 'comment_content', with: "Great pixi. I highly recommend it.\n" 
	        sleep 3
        }.to change(Comment,:count).by(1)
        expect(page).to have_content "Comments (#{pixi_post_listing.comments.size})"
        expect(page).to have_content "Great pixi. I highly recommend it." 
        expect(page).to have_content @user.name 
        expect(page).not_to have_field('#comment_content', with: 'Great pixi')      
      end
    end


    context "Clicks Buy Now", js: true do
      before :all do
        load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
        Rake::Task.define_task(:environment)
        Rake::Task["load_fulfillment_types"].execute
        site = create :site
        business_user = create :business_user
        business_user.bank_accounts.create attributes_for :bank_account
        @business_listing = create(:listing, title: "Guitar", description: "Test",
          seller_id: business_user.id, quantity: 2, site_id: site.id, fulfillment_type_code: "SHP",
          sales_tax: 8.25, est_ship_cost: 10.0, buy_now_flg: true)
      end

      def buy_now_test(model)
        init_setup user
        visit listing_path(@business_listing)
        expect {
            click_link 'Want'; sleep 2
            click_link 'Buy Now'
            sleep 5
            expect(page).not_to have_link 'Want'
            expect(page).to have_content 'Buyer Information'
            expect(page).to have_content 'Shipping Information'
        }.to change(model, :count).by(1)
      end

      it 'creates want' do
        buy_now_test(PixiWant)
      end

      it 'creates invoice' do
        buy_now_test(Invoice)
      end

      it 'multiple times' do
        buy_now_test(PixiWant)
        visit listing_path(@business_listing)
        expect(page).to have_link 'Want'
      end
    end

    it "Asks a seller", js: true do
      expect{
          expect(page).to have_link 'Ask'
          expect(page).to have_link 'Cool'
          click_link 'Ask'
          sleep 3
          fill_in 'ask_content', with: "What color is the item?\n" 
          click_button 'Send'
          sleep 5
          expect(page).to have_content 'Successfully sent message to seller'
      }.to change(Post,:count).by(1)

      expect{
          expect(page).to have_link 'Ask'
          expect(page).to have_link 'Cool'
          click_link 'Ask'
          sleep 3
          fill_in 'ask_content', with: "Is this a new item?\n" 
          click_button 'Send'
          sleep 5
          expect(page).to have_content 'Successfully sent message to seller'
      }.to change(Post,:count).by(1)
      expect(Conversation.count).to eq 1
    end
     
    it "does not contact a seller", js: true do
      expect{
          expect(page).to have_link 'Want'
          click_link 'Want'
          sleep 3
	        click_link 'Close'
          expect(page).not_to have_content 'Successfully sent message to seller'
      }.not_to change(Post,:count)
    end

    it "does not ask a seller", js:true do
      expect{
          expect(page).to have_link 'Ask'
          click_link 'Ask'
          sleep 3
          click_link 'Close'
          expect(page).not_to have_content 'Successfully sent message to seller'
      }.not_to change(Post,:count)
    end

    it "cannot ask seller with empty text box", js:true do
          expect(page).to have_link 'Ask'
          click_link 'Ask'
          sleep 3
          expect(page).not_to have_link 'Send'
    end

    it "clicks on Cool", js: true do
      expect{
          page.find('#cool-btn').click
	        sleep 3
          expect(page).to have_link 'Uncool'
          expect(page).not_to have_link 'Cool'
      }.to change(PixiLike,:count).by(1)
      expect(page).to have_content listing.nice_title(false)
      expect(page).to have_content "(#{listing.liked_count})"
    end

    it "clicks on Save", js: true do
      expect{
          page.find('#save-btn').click
	  sleep 3
          expect(page).to have_link 'Unsave'
      }.to change(SavedListing,:count).by(1)

      expect(page).to have_content listing.nice_title(false)
    end
  end

  describe "Contact Owner w/ quantity > 1", contact: true do 
    it "seller want request", js: true do
      pixi_user = create(:pixi_user)
      init_setup pixi_user
      visit listing_path(post_listing) 
      want_request false, 2
    end
  end

  describe "Contact Owner with external url", contact: true do 
    before do
      pixi_user = create(:pixi_user)
      init_setup pixi_user
      post_listing.update_attribute(:external_url, 'http://www.google.com')
      visit listing_path(post_listing) 
    end
    it "submits want request", js: true do
      expect {
        expect(page).to have_link 'Want'
        expect(page).to have_link 'Ask'
        expect(page).to have_link 'Cool'
        click_link 'Want'
        sleep 2
        click_link 'Send'
        sleep 5
        page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)   # exit popup window
        expect(page).not_to have_link 'Want'
        expect(page).to have_content 'Want'
      }.to change(PixiWant, :count).by(1)
      expect(PixiWant.first.quantity).to eql(1)
    end
  end

  describe "View Pixi w/ buyer flags set", contact: true do 
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
      expect(page).to have_content 'Want'
      expect(page).not_to have_link 'Want', href: '#'
      page.find_link('Uncool').visible?
      expect(page).not_to have_link 'Cool'
      expect(page).to have_link 'Unsave'
    end

    it "clicks on Uncool", js: true do
      expect{
          page.find('#cool-btn').click
	  sleep 3
          expect(page).not_to have_link 'Uncool'
          expect(page).to have_link 'Cool'
      }.to change(PixiLike,:count).by(-1)
      expect(page).to have_content listing.nice_title(false)
      expect(page).to have_content "(#{listing.liked_count})"
    end

    it "clicks on Unsave", js: true do
      expect{
          page.find('#save-btn').click
	  sleep 3
          expect(page).to have_link 'Save'
      }.to change(SavedListing,:count).by(-1)
      expect(page).to have_content listing.nice_title(false)
    end
  end

  describe "View Event Pixi", event: true do 
    it_should_behave_like "event_listings", 100.00
    it_should_behave_like "event_listings", nil
  end

  describe "View Owned Pixi", owned: true do 
    it_should_behave_like 'owner_listings', 'sold', 'pixi_user'
    it_should_behave_like 'owner_listings', 'active', 'pixi_user'
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
      expect(page).not_to have_content "Start Date: #{short_date(job_listing.event_start_date)}"
      expect(page).not_to have_content "End Date: #{short_date(job_listing.event_end_date)}"
      expect(page).not_to have_content "Start Time: #{short_time(job_listing.event_start_time)}"
      expect(page).not_to have_content "End Time: #{short_time(job_listing.event_end_time)}"
      expect(page).not_to have_content "Price: #{(job_listing.price)}"
      expect(page).not_to have_content "Event Type: #{job_listing.event_type_descr}"
      expect(page).not_to have_content "Condition: #{(job_listing.condition)}"
      expect(page).not_to have_content "Amount Left: #{(job_listing.amt_left)}"
      expect(page).to have_content "Job Type: #{(job_listing.job_type_name)}"
      expect(page).to have_content "Compensation: #{(job_listing.compensation)}"
    end
  end

  describe "Pixter-viewed Pixi", owned: true do 
    it_should_behave_like 'owner_listings', 'active', 'pixter'
  end

  describe "Admin-viewed Pixi", owned: true do 
    it_should_behave_like 'owner_listings', 'active', 'admin'
  end

  describe "Add Comments", process: true do 
    before(:each) do
      pixi_user = create(:pixi_user) 
      init_setup pixi_user
      visit listing_path(listing) 
      page.find('#comment-tab').click
    end

    it "views pixi page" do
      expect(page).to have_content "No comments found."
      expect(page).to have_content "Comments (#{listing.comments.size})"
    end
     
    it "adds a comment", js: true do
      expect{
      	  fill_in 'comment_content', with: "Great pixi. I highly recommend it.\n" 
	  sleep 3
      }.to change(Comment,:count).by(1)

      expect(page).to have_content "Comments (#{listing.comments.size})"
      expect(page).to have_content "Great pixi. I highly recommend it." 
      expect(page).to have_content @user.name 
      expect(page).not_to have_field('#comment_content', with: 'Great pixi')
    end
     
    it "does not add a comment", js: true do
      expect{
	  fill_in 'comment_content', with: "\n"
      }.not_to change(Comment,:count)
    end
  end

  describe "comments pagination", process: true do
    before(:each) do
      pixi_user = create(:pixi_user) 
      init_setup pixi_user
      10.times { listing.comments.create attributes_for(:comment, user_id: pixi_user.id) } 
      visit listing_path(listing) 
      page.find('#comment-tab').click
    end

    it { is_expected.to have_selector('div.pagination') }

    it "should list each comment" do
      listing.comments.paginate(page: 1).each do |comment|
        expect(page).to have_selector('li', text: comment.summary)
      end
    end
  end

  describe "Check Pixis", main: true do 
    before(:each) do
      editor = create :editor, email: 'jsnow@pixitext.com', confirmed_at: Time.now 
      @listing = create :listing, seller_id: editor.id, condition_type_code: condition_type.code
      @pixi_want = editor.pixi_wants.create attributes_for :pixi_want, pixi_id: @listing.pixi_id
      @pixi_like = editor.pixi_likes.create attributes_for :pixi_like, pixi_id: @listing.pixi_id
      init_setup editor
    end

    context "Review Pixis" do 
      before { visit listing_path(@listing) }

      it "Deletes a pixi" do
        expect {
          click_link 'Sold Item'; sleep 2
          expect(page).not_to have_content @listing.title 
          expect(page).to have_content "Pixis" 
        }.to change(Listing, :count).by(0)
	expect(@listing.reload.status).to eq('removed')
      end

      describe "Edits active pixi" do
        it "adds a pixi pic", js: true do
          click_link 'Edit'; sleep 3
          expect(page).to have_content("Build Your Pixi") 
          expect(page).to have_selector('#build-pixi-btn')
          expect{
	    fill_in 'Title', with: 'Rhodes Bass Guitar'
            attach_file('photo', Rails.root.join("spec", "fixtures", "photo0.jpg"))
            page.find('#build-pixi-btn').click
            expect(page).to have_content 'Review Your Pixi'
            click_link 'Done!'
            expect(page).to have_content 'Rhodes Bass Guitar'
            visit pending_listing_path(@listing) 
            expect(page).to have_content 'Rhodes Bass Guitar'
            expect(page).to have_button('Deny')
            expect(page).to have_link 'Approve', href: approve_pending_listing_path(@listing)
            click_link 'Approve'; sleep 2;
	    visit listing_path(@listing)
            expect(page).to have_content 'Rhodes Bass Guitar'
            expect(@listing.wanted_count).to eq(1)
            expect(@listing.liked_count).to eq(1)
            expect(@listing.pictures.count).to eq(2)
            expect(Listing.where(seller_id: @user.id).count).to eq(1)
            # TempListing.where(pixi_id: @listing.pixi_id).count.should eq(0)
            # TempListing.where("title like 'Rhodes%'").count.should eq(0)
            expect(Listing.where("title like 'Rhodes%'").count).to eq(1)
            expect(Listing.where("title like 'Acoustic%'").count).to eq(0)
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
        expect(page).to have_content('Pixis')
        expect(page).to have_content 'Guitar'
        expect(page).not_to have_content 'No pixis found'
      end

      it "does not show status type" do
        expect(page).not_to have_content "Status"
      end
    end  

    describe "featured sellers" do  
      before(:each) do
        add_business_sellers
        create(:listing, title: "Guitar", seller_id: @user.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Acoustic Guitar", seller_id: @seller1.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Bass Guitar", seller_id: @seller2.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Electric Guitar", seller_id: @seller3.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Uke Guitar", seller_id: @seller4.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Rhodes Guitar", seller_id: @seller5.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Fender Guitar", seller_id: @seller1.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Rhythm Guitar", seller_id: @seller2.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "White Guitar", seller_id: @seller3.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Black Guitar", seller_id: @seller4.id, site_id: site.id, category_id: category.id) 
        create(:listing, title: "Blue Guitar", seller_id: @seller5.id, site_id: site.id, category_id: category.id) 
        visit local_listings_path(cid: category.id, loc: site.id) 
      end

      it 'has featured band' do
        expect(page).to have_content 'Featured Sellers'
        expect(page).to have_content @seller1.name
      end
    end  

    describe "GET /local" do  
      let(:listings) { 10.times { create(:listing, seller_id: @user.id, category_id: category.id, site_id: site.id) } }

      before(:each) do
        create(:listing, title: "Guitar", seller_id: @user.id, site_id: site.id, category_id: category.id) 
        visit local_listings_path(cid: category.id, loc: site.id) 
      end
      
      it "views pixi category page" do
        expect(page).to have_content('Pixis')
        expect(page).to have_content 'Guitar'
        expect(page).not_to have_content 'Featured Sellers'
        expect(page).not_to have_content 'No pixis found'
      end

      it "does not show status type" do
        expect(page).not_to have_content "Status"
      end
    end  

    describe "GET /listings" do  
      let(:listings) { 30.times { create(:listing, seller_id: @user.id) } }

      before(:each) do
        add_region
        @site = create :site, name: 'Detroit', site_type_code: 'city'
	      @site.contacts.create attributes_for :contact, address: '1611 Tyler', city: 'Detroit', state: 'MI', zip: '48238'
        @site3 = create :site, name: 'Pixi Tech', site_type_code: 'school'
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
        expect(page).to have_link 'Recent'
        expect(page).to have_content('Pixis')
        expect(page).not_to have_content 'No pixis found'
      end
      
      it "scrolls listings", js: true do 
        page.execute_script "window.scrollBy(0,1000)"
      end

      it "searches for a listing", js: true do
        fill_in 'search', with: 'guitar'
	      click_on 'submit-btn'
        expect(page).not_to have_content 'HP Printer J4580'
      end

      it "selects a site", js: true do
        fill_autocomplete('site_name', with: 'pixi')
	      set_site_id @site3.id; sleep 2
        expect(page).to have_content @listing1.title
        expect(page).to have_content @pixi.title
        expect(page).to have_content @site3.name
      end

      it "selects categories", js: true do
        fill_autocomplete('site_name', with: 'pixi')
	      set_site_id @site3.id; sleep 2
        select('Music', :from => 'category_id'); sleep 2
        expect(page).to have_content @category.name_title
        expect(page).not_to have_content @listing1.title
        expect(page).to have_content 'Guitar'
      end
    end
  end
end
