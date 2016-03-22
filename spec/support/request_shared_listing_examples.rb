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
    selector, content = factory == 'pixi_user' ? ['not_to', 'to'] : ['to', 'not_to']
    expect(page).send(selector, have_selector('#comment_content'))
    expect(page).send(selector, have_selector('#cool-btn'))
    expect(page).send(selector, have_selector('#save-btn'))
    expect(page).send(selector, have_selector('#wantDialog'))
    expect(page).send(selector, have_selector('#askDialog'))
    expect(page).send(content, have_content("#{listing.wanted_count} Wants"))
    expect(page).send(content, have_content("#{listing.asked_count} Asks"))
    expect(page).send(content, have_content("#{listing.liked_count} Cools"))
    expect(page).send(content, have_content("#{listing.saved_count} ZZZZSaves"))
  end

  describe 'Review Pixi', owned: true do
    it "views pixi page" do
      init_setup set_user(factory)
      visit listing_path listing
      expect(page).to have_content "#{listing.seller_name}"
      expect(page).to have_selector('#detail-tab')
      expect(page).to have_selector('#comment-tab')
      expect(page).not_to have_selector('#contact_content')
      expect(page).not_to have_selector('#send-want-btn')
      expect(page).to have_selector('#fb-link')
      expect(page).to have_selector('#tw-link')
      expect(page).to have_selector('#pin-link')
      expect(page).not_to have_link 'Follow', href: '#'
      expect(page).to have_content "Condition: #{listing.condition}"
      expect(page).to have_content "Comments (#{listing.comments.size})"
      expect(page).not_to have_link 'Cancel', href: root_path
      get_method factory

      if val == 'active'
        expect(page).to have_content "Amount Left: #{listing.amt_left}" 
	if factory == 'pixi_user'
          expect(page).to have_link 'Edit', href: edit_temp_listing_path(listing, ptype:'')
	else
          expect(page).to have_link 'Edit', href: edit_temp_listing_path(listing, ptype:'mbr')
	end
        expect(page).to have_button 'Remove'
      else
        expect(page).not_to have_content "Amount Left: #{listing.amt_left}" 
        expect(page).not_to have_link 'Edit', href: edit_temp_listing_path(listing)
        expect(page).not_to have_button 'Remove'
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
      expect(page).to have_content "Amount Left: #{(event_listing.amt_left)}"
    end
  end
end

shared_examples 'want_request' do |sFlg, qty|
  describe 'Review Pixi', seller: true do
    it 'contacts seller' do
      expect{
          expect(page).to have_link 'Want'
          expect(page).to have_link 'Ask'
          expect(page).to have_link 'Cool'
          click_link 'Want'; sleep 2
          check_page_selectors ['#px-qty'], true, sFlg
          if qty > 1
            select("#{qty}", :from => "px-qty")
          end
          click_button 'Send'
          sleep 5
          expect(page).not_to have_link 'Want'
          expect(page).to have_content 'Want'
          expect(page).to have_content 'Successfully sent message to seller'
      }.to change(Post,:count).by(1)
      expect(Conversation.count).to eql(1)
      expect(PixiWant.first.quantity).to eql(qty)
    end
  end
end
