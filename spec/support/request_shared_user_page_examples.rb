require 'spec_helper'

shared_examples 'user_show_pages' do |name, type, url, flg, done_flg|
  describe 'show user page' do
    it 'renders show page' do
      page.should have_content name
      page.should have_content 'Facebook Login' if done_flg
      page.should have_content 'Member Since'
      page.should have_content 'Type'
      page.should have_content type
      page.should have_content 'URL'
      page.should have_content url
      page.should have_selector('#usr-edit-btn', visible: flg) if done_flg
      page.should have_selector('#usr-done-btn', visible: flg) if done_flg
    end
  end
end
