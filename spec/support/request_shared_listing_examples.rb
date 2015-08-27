require 'spec_helper'

shared_examples 'owner_listings' do |val, factory|
  let (:usr) { create factory.to_sym }
  let (:listing) { create :listing, title: "Guitar", description: "Lessons", seller_id: user.id,
        site_id: site.id, status: val, quantity: 1, condition_type_code: condition_type.code, pixan_id: set_id(factory)}

  def set_id factory
    factory == 'pixter' ? usr.id : nil
  end

  def set_user factory
    factory == 'pixi_user' ? user : usr
  end

  def get_method factory
    selector, content = factory == 'pixi_user' ? ['should_not', 'should'] : ['should', 'should_not']
      page.send(selector, have_selector('#comment_content'))
      page.send(selector, have_selector('#cool-btn'))
      page.send(selector, have_selector('#save-btn'))
      page.send(selector, have_selector('#want-btn'))
      page.send(selector, have_selector('#ask-btn'))
      page.send(content, have_content("#{listing.wanted_count}Wants"))
      page.send(content, have_content("#{listing.asked_count}Asks"))
      page.send(content, have_content("#{listing.liked_count}Cools"))
      page.send(content, have_content("#{listing.saved_count}Saves"))
  end

  describe 'Review Pixi', owned: true do
    it "views pixi page" do
      init_setup set_user(factory)
      visit listing_path listing
      page.should have_content "#{listing.seller_name}"
      page.should have_selector('#detail-tab')
      page.should have_selector('#comment-tab')
      page.should_not have_selector('#contact_content')
      page.should_not have_selector('#send-want-btn')
      page.should have_selector('#fb-link')
      page.should have_selector('#tw-link')
      page.should have_selector('#pin-link')
      page.should_not have_link 'Follow', href: '#'
      page.should have_content "Condition: #{listing.condition}"
      page.should have_content "Comments (#{listing.comments.size})"
      page.should_not have_link 'Cancel', href: root_path
      get_method factory

      if val == 'active'
        page.should have_content "Amount Left: #{listing.amt_left}" 
	if factory == 'pixi_user'
          page.should have_link 'Edit', href: edit_temp_listing_path(listing, ptype:'')
	else
          page.should have_link 'Edit', href: edit_temp_listing_path(listing, ptype:'mbr')
	end
        page.should have_button 'Remove'
      else
        page.should_not have_content "Amount Left: #{listing.amt_left}" 
        page.should_not have_link 'Edit', href: edit_temp_listing_path(listing)
        page.should_not have_button 'Remove'
      end
    end
  end
end

shared_examples 'event_listings' do |val|
  let(:event_type) { create :event_type }
  let(:category) { create :category, name: 'Event', category_type_code: 'event' }
  let(:event_listing) { create(:listing, title: "Guitar", description: "Lessons", seller_id: user.id, pixi_id: temp_listing.pixi_id, 
      category_id: category.id, event_start_date: Date.tomorrow, event_end_date: Date.tomorrow, event_start_time: Time.now+2.hours, price: val,
      event_end_time: Time.now+3.hours, event_type_code: event_type.code, quantity: 1 ) }

  describe 'Review Pixi', event: true do
    it 'views event pixi' do
      init_setup user
      visit listing_path(event_listing) 
      check_page_expectations ["#{event_listing.nice_title(false)}", "#{event_listing.seller_name}", "ID: #{event_listing.pixi_id}", "Posted:", 
      "Updated:", "Date(s):", "Time(s):", "Event Type:", "#{event_listing.event_type_descr}"], '', false
      # check_page_selectors ['#contact_content', '#comment_content'], false, true
      check_page_expectations ["Condition:", "Compensation:", "Job Type:", "Year:", 'VIN #:', 'Product Code:', 'Color:', 'Size:'], '', true
      page.should have_content "Amount Left: #{(event_listing.amt_left)}"
    end
  end
end

shared_examples 'want_request' do |sFlg, qty|
  describe 'Review Pixi', seller: true do
    it 'contacts seller' do
      expect{
          page.should have_link 'Want'
          page.should have_link 'Ask'
          page.should have_link 'Cool'
          click_link 'Want'; sleep 2
          check_page_selectors ['#px-qty'], true, sFlg
          if qty > 1
            select("#{qty}", :from => "px-qty")
          end
          click_button 'Send'
          sleep 5
          page.should_not have_link 'Want'
          page.should have_content 'Want'
          page.should have_content 'Successfully sent message to seller'
      }.to change(Post,:count).by(1)
      expect(Conversation.count).to eql(1)
      expect(PixiWant.first.quantity).to eql(qty)
    end
  end
end
