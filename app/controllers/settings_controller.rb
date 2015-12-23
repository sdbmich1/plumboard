class SettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_vars, :set_user
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def index
    respond_with(@usr)
  end

  def password
    respond_with(@usr)
  end

  def contact
    respond_with(@usr)
  end

  def details
    respond_with(@usr)
  end

  def delivery
    respond_with(@usr)
  end
   
  private

  def set_user
    @usr = params[:id].blank? ? @user : User.find(params[:id])
  end

  def load_vars
    @adminFlg = params[:adminFlg] || false
  end

  def page_layout
    mobile_device? ? 'form' : 'application'
  end
end
