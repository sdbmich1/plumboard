require 'spec_helper'

describe "ShopLocals" do
  subject { page }

  describe "Shop Locals page" do
    before { visit "http://shoplocal.pixiboard.com" }
    it 'shows content' do
      expect(page).to have_link 'About', href: '#about'
      expect(page).to have_link 'Businesses', href: '#biz'
      expect(page).to have_link 'Individuals', href: '#ind'
      expect(page).to have_link 'Login', href: '#loginDialog'
      expect(page).to have_link 'Signup', href: '#signupDialog'
      %w(about join biz ind).each do |section|
        expect(page).to have_content "#{SLS_KEYS[section]['header']}"
      end
    end
  end

  describe "not visit shop locals page" do
    before { visit "http://game.pixiboard.com" }
    it 'shows content' do
      expect(page).not_to have_link 'Businesses', href: '#biz'
      expect(page).not_to have_link 'Individuals', href: '#ind'
    end
  end
end
