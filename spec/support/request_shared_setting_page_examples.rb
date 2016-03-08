require 'spec_helper'

  def general_settings usr, val
    expect(page).to have_content("Settings")
      expect(page).to have_link("Account", href: "/users/#{usr.id}")
      expect(page).to have_link("Profile", href: settings_path(id: usr))
      expect(page).to have_link("Contact", href: settings_contact_path(id: usr))
      expect(page).to have_link("Password", href: settings_password_path(id: usr))
      expect(page).to have_link("Delivery", href: settings_delivery_path(id: usr)) if usr.is_business?
  end

  def account_settings usr
    expect(page).to have_content("#{usr.name}")
    expect(page).to have_content("Pixis Posted")
    expect(page).to have_content("Member Since")
    expect(page).to have_content("URL")
    expect(page).to have_content("#{usr.user_url}")
  end

  def delivery_settings usr, msg
    page.send(msg, have_content("Delivery"))
    if msg == 'should'
      click_link 'Delivery'
      expect(page).to have_content("Delivery Type")
      expect(page).to have_content("Sales Tax")
      expect(page).to have_content("Ship Amt")
    end
  end

  def profile_settings usr
    click_link 'Profile'
    # page.should have_content("#{usr.first_name}")
    expect(page).to have_selector("#user_first_name")
    expect(page).to have_selector('#usr_photo')
  end

  def contact_settings usr
    click_link 'Contact'
    expect(page).to have_content("Home Phone")
    expect(page).to have_content("Address")
  end

  def set_accts factory, factory2, flg
    @usr = create factory.to_sym, confirmed_at: Time.now 
    if flg
      @usr2 = create factory2.to_sym, confirmed_at: Time.now 
      init_setup @usr2
    else
      init_setup @usr
    end
  end

shared_examples 'setting_pages' do |factory, factory2, msg, val, flg|
  describe 'setting methods' do
    before :each do
      set_accts factory, factory2, flg
      visit "/users/#{@usr.id}"
    end

    it "should display settings menu" do 
      general_settings @usr, flg
    end

    it 'should show account page' do
      account_settings @usr
    end

    it 'should show profile page', js: true do
      profile_settings @usr
    end

    it 'should show contact page', js: true do
      contact_settings @usr
    end

    it 'should show password page', js: true do
      click_link 'Password'
      expect(page).to have_content("Password")
    end

    it 'should show delivery page', js: true do
      delivery_settings @usr, msg
    end
  end
end
