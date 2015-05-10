class SettingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def index
    respond_with(@usr = current_user)
  end

  def password
    respond_with(@usr = current_user)
  end

  def contact
    respond_with(@usr = current_user)
  end

  def details
    respond_with(@usr = current_user)
  end
   
  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end
end
