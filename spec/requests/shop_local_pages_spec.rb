require 'spec_helper'

describe "ShopLocals" do
  subject { page }

  describe "Shop Locals page" do
    before { visit "http://shoplocal.pixiboard.com" }
    it 'shows content' do
      page.should have_link 'About', href: '#about'
      page.should have_link 'Businesses', href: '#biz'
      page.should have_link 'Individuals', href: '#ind'
      page.should have_link 'Login', href: '#loginDialog'
      page.should have_link 'Signup', href: '#signupDialog'
      %w(about join biz ind).each do |section|
        page.should have_content "#{SLS_KEYS[section]['header']}"
      end
    end
  end

  describe "not visit shop locals page" do
    before { visit "http://game.pixiboard.com" }
    it 'shows content' do
      page.should_not have_link 'Businesses', href: '#biz'
      page.should_not have_link 'Individuals', href: '#ind'
    end
  end
end
