class SettingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

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
end
