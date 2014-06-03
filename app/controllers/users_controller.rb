require 'will_paginate/array' 
class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, :check_permissions, only: [:index, :show]
  before_filter :load_target, only: [:update]
  respond_to :html, :js, :json, :mobile

  def index
    @users = User.get_by_type(@utype).paginate(page: @page, per_page: 15)
    respond_to do |format|
      format.html
      format.csv {send_data User.to_csv}
    end
  end

  def show
    @usr = User.find params[:id]
    @photo = @usr.pictures
  end

  def edit
    @usr = User.find params[:id]
  end

  def update
    authorize! :update, User
    @usr = User.find params[:id]
    changing_email = params[:user][:email] != @usr.email
    if @usr.update_attributes(params[:user])
      flash.now[:notice] = flash_msg changing_email
      @usr = User.find params[:id]
    else
      respond_with(@usr)
    end
  end

  def states
    respond_with(@states = State.all)
  end

  def buyer_name
    @users = User.search query, star: true, :page => params[:page], :per_page => 10
    respond_with(@users)
  end

  private

  def load_target
    @target = params[:target]
  end

  # loads confirmation message
  def flash_msg chg_email
    if chg_email 
      (@usr.pending_reconfirmation?) ?
        t("devise.registrations.update_needs_confirmation") : t("devise.registrations.updated")
    else 
      'Saved changes successfully.'
    end
  end

  def query
    @query = Riddle::Query.escape params[:search]
  end 

  def load_data
    @utype = params[:utype]
    @page = params[:page] || 1
  end 

  def check_permissions
    authorize! :manage, @users
  end
      
end
