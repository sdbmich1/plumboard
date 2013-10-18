class SettingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :mobile
  layout :page_layout

  def index
    @user = current_user
  end

  def password
    @user = current_user
  end

  def contact
    @user = current_user
    @contacts = @user.contacts.blank? ? @user.contacts.build : @user.contacts
  end
   
  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

end
