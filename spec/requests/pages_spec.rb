require 'spec_helper'

describe "Pages" do
  subject { page }

  describe "Home page" do
    before { visit root_path }
    it { should have_selector('h1', :text => full_title('')) }
    it { should have_selector('title', text: full_title('')) }
    it { should_not have_selector('title', text: '| Home') }
  end

  describe "Help page" do
    before { visit help_path }
    it { should have_selector('h1', text: 'Help') }
    it { should have_selector('title', :text => full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }
    it { should have_selector('h1', text: 'About Us') }
    it { should have_selector('title', text: full_title('About Us')) }
  end

  describe "Contact page" do
    before { visit contact_path }
    it { should have_selector('h1',    text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end

  describe "Privacy page" do
    before { visit privacy_path } 
    it { should have_selector('h1',    text: 'Privacy') }
    it { should have_selector('title', text: full_title('Privacy')) }
  end

  describe "Welcome page" do
    before { visit welcome_path } 
    it { should have_selector('h1',    text: 'Welcome') }
    it { should have_selector('title', text: full_title('Welcome')) }
  end
end
