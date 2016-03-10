require 'spec_helper'
require 'rake'

describe 'manage_server' do
  before :all do
    load File.expand_path("../../../lib/tasks/manage_server.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  describe 'close_expired_pixis' do
    it_behaves_like("manage_server", "manage_server:close_expired_pixis", nil, Listing, 'close_pixis')
  end

  describe "import_job_feed" do
    it_behaves_like("manage_server", "manage_server:import_job_feed", nil, LoadNewsFeed, 'import_job_feed')
  end

  describe "load_news_feeds" do
    it_behaves_like("manage_server", "manage_server:load_news_feeds", nil, LoadNewsFeed, 'read_feeds')
  end

  describe 'send_expiring_draft_pixi_notices' do
    it_behaves_like("manage_server", "manage_server:send_expiring_draft_pixi_notices", {arg1: 7}, TempListing, 'soon_expiring_pixis')
  end

  describe 'send_expiring_pixi_notices' do
    it_behaves_like("manage_server", "manage_server:send_expiring_pixi_notices", {arg1: 7}, Listing, 'soon_expiring_pixis')
  end

  describe 'send_invoiceless_pixi_notices' do
    it_behaves_like("manage_server", "manage_server:send_invoiceless_pixi_notices", nil, Listing, 'invoiceless_pixis')
  end

  describe 'send_unpaid_old_invoice_notices' do
    it_behaves_like("manage_server", "manage_server:send_unpaid_old_invoice_notices", nil, Invoice, 'unpaid_old_invoices')
  end

  describe 'update_buy_now' do
    [Listing, TempListing].each do |model|
      it_behaves_like("manage_server", "manage_server:update_buy_now", nil, model, 'update_buy_now')
    end
  end

  describe 'update_fulfillment_types' do
    [Listing, TempListing].each do |model|
      it_behaves_like("manage_server", "manage_server:update_fulfillment_types", nil, model, 'update_fulfillment_types')
    end
  end

  describe 'set_delivery_preferences' do
    it 'assigns default values for business users' do
      business_user = create :business_user
      Rake::Task['manage_server:set_delivery_preferences'].execute
      business_user.preferences.first.reload
      expect(business_user.preferences.first.ship_amt).to eq 10.0
      expect(business_user.preferences.first.sales_tax).to eq 8.25
      expect(business_user.preferences.first.fulfillment_type_code).to eq 'P'
    end

    it 'does not override preferences that are already assigned' do
      business_user = create :business_user
      pref = business_user.preferences.first
      pref.ship_amt = 0.0
      pref.sales_tax = 9.0
      pref.fulfillment_type_code = 'SHP'
      pref.save
      expect {
        Rake::Task['manage_server:set_delivery_preferences'].execute
      }.not_to change { business_user.preferences }
    end

    it 'does not assign values for non-business users' do
      user = create :pixi_user
      attrs = { ship_amt: nil, sales_tax: nil, fulfillment_type_code: nil }
      user.preferences.create(attrs)
      expect {
        Rake::Task['manage_server:set_delivery_preferences'].execute
      }.not_to change { user.preferences }
    end
  end

  describe 'set_ship_address_user_ids' do
    it 'assigns user_id' do
      user = create :pixi_user
      ship_address = ShipAddress.create(recipient_first_name: user.first_name,
        recipient_last_name: user.last_name, recipient_email: user.email)
      expect(ship_address.user_id).to be_nil
      Rake::Task['manage_server:set_ship_address_user_ids'].execute
      expect(ship_address.reload.user_id).to eq user.id
    end
  end
end