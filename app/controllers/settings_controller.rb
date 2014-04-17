class SettingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def index
    respond_with(@usr = current_user)
  end

  def password
    respond_with(@user = current_user)
  end

  def contact
    @user = current_user
    @contacts = @user.contacts.blank? ? @user.contacts.build : @user.contacts
    respond_with(@user) do |format|
      format.json { render json: {user: @user, contacts: @contacts} }
    end
  end
   
  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

end
