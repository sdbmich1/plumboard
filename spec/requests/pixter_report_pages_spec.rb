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
  let(:submit) { "Register" } 
  let(:zip) { create(:pixi_post_zip) }

  describe "pixter visits Pixter Report WITHOUT posts", pixter: true do
    before do
      init_setup pixter
      visit pixter_report_pixi_posts_path(status: 'pixter_report')
    end

    it "it should display 'No Posts Found'", js: true do
      expect(page).to have_content 'No posts found'
    end
    it "should have a selector for date range", js: true do
      expect(page).to have_selector('#date_range_name', visible: true)
    end
    it "should not have a selector for pixter list", js: true do
      expect(page).not_to have_selector('#user_id', visible: true)
    end
    it "should not have a link Export to CSV", js: true do
      expect(page).not_to have_link('#csv-exp', visible: true)
    end
    it "should not have content 'Pixter Report for'", js: true do
      expect(page).to have_content("Pixter Report for")
    end
  end

  describe "pixter visits Pixter Report WITH posts", pixter: true do
    before do
      init_setup pixter
      @pixi_post_zip = create(:pixi_post_zip)
      @listing_completed = create :listing, seller_id: user.id, pixan_id: @user.id
      @listing_sold = create :listing, seller_id: user.id, pixan_id: @user.id
      @invoice = build :invoice, buyer_id: user.id, seller_id: user.id
      @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing_sold.pixi_id 
      @invoice.save!
      @invoice.update_attribute(:status, 'paid')
      @completed = user.pixi_posts.build attributes_for :pixi_post, pixan_id: @user.id, appt_date: Time.now,
                    appt_time: Time.now, completed_date: Time.now, description: 'rocking chair', status: 'completed'
      @completed.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing_completed.pixi_id
      @completed.save!
      @sold = user.pixi_posts.build attributes_for :pixi_post, pixan_id: @user.id, appt_date: Time.now,
                    appt_time: Time.now, completed_date: Time.now, description: 'rocking chair', status: 'sold'
      @sold.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing_sold.pixi_id
      @sold.save!
      visit pixter_report_pixi_posts_path(status: 'pixter_report')
    end
    it "should not have a content 'no posts found'", js: true do
      expect(page).not_to have_content 'No posts found'
    end
    it "should contain the pixter name", js: true do
      expect(page).to have_content @user.name
    end
    it "should have sale amt and revenue", js: true do
      expect(page).to have_content @details.subtotal
      expect(page).to have_content @sold.revenue
    end
  end

  describe "admin visits Pixter Report WITHOUT posts", admin: true do
    before do
      init_setup admin
      visit pixter_report_pixi_posts_path(status: 'pixter_report')
    end

    it "should display 'No Posts Found'", js: true do
      expect(page).to have_content 'No posts found'
    end
    it "should have a selector for date range", js: true do
      expect(page).to have_selector('#date_range_name', visible: true)
    end
    it "should have a selector for pixter list", js: true do
      expect(page).to have_selector('#user_id', visible: true)
    end
    it "should not have a link Export to CSV", js: true do
      expect(page).not_to have_link('#csv-exp', visible: true)
    end
    it "should no have content 'Pixter Report for'", js: true do
      expect(page).to have_content("Pixter Report for")
    end
  end

  describe "admin visits Pixter Report WITH posts", admin: true do
    before do
      init_setup admin
      @date_range = create :date_range
      @pixi_post_zip = create(:pixi_post_zip)
      @listing_completed_pt1 = create :listing, seller_id: user.id, pixan_id: pixter.id
      @listing_completed_pt2 = create :listing, seller_id: user.id, pixan_id: pixter2.id
      @completed_pt1 = user.pixi_posts.build attributes_for :pixi_post, pixan_id: pixter.id, appt_date: Time.now,
                    appt_time: Time.now, completed_date: Time.now, description: 'rocking chair', status: 'completed'
      @completed_pt1.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing_completed_pt1.pixi_id
      @completed_pt1.save!
      @completed_pt2 = user.pixi_posts.build attributes_for :pixi_post, pixan_id: pixter2.id, appt_date: Time.now,
                    appt_time: Time.now, completed_date: Time.now, description: 'house stuff', status: 'completed'
      @completed_pt2.pixi_post_details.build attributes_for :pixi_post_detail, pixi_id: @listing_completed_pt2.pixi_id
      @completed_pt2.save!
      visit pixter_report_pixi_posts_path(status: 'pixter_report')
    end

    it "should have both pixters' names", js: true do
      expect(page).to have_content pixter.name
      expect(page).to have_content pixter2.name
    end

    it "should only have pixter1's name", js: true do
      select(pixter.first_name, :from => 'user_id')
      expect(page).to have_content "for #{pixter.name}"
      expect(page).not_to have_content "for #{pixter2.name}"
    end

    it "should have No Posts Found content", js: true do
      expect(page).to have_selector('#date_range_name', visible: true)
      select("Last Month", :from => 'date_range_name')
      expect(page).not_to have_content("No Posts Found")
    end
  end
end
