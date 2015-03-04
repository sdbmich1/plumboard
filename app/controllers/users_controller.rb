require 'will_paginate/array' 
class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, :check_permissions, only: [:index, :show]
  before_filter :load_target, :check_update_permissions, only: [:update]
  before_filter :get_user, only: [:show, :edit, :update]
  respond_to :html, :js, :json, :mobile, :csv

  def index
    @unpaginated_users = User.include_list.get_by_type(@utype)
    respond_with(@users = @unpaginated_users.paginate(page: @page, per_page: 15)) { |format| render_csv format }
  end

  def show
  end

  def edit
  end

  def update
    changing_email = params[:user][:email] != @usr.email
    if @usr.update_attributes(params[:user])
      if is_profile?  
        redirect_to get_user_path, notice: 'Saved changes successfully'
      else 
        flash.now[:notice] = flash_msg changing_email
        get_user
      end
    else
      respond_with(@usr)
    end
  end

  def states
    respond_with(@states = State.all)
  end

  def buyer_name
    respond_with(@users = User.search(query, star: true, :page => params[:page], :per_page => 10))
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
    @utype, @page = params[:utype], params[:page] || 1
  end 

  def get_user
    @usr = User.find params[:id]
  end

  def is_profile?
    !@target.match(/form/).nil?
  end

  def get_user_path
    @usr == @user ? settings_path : @usr
  end

  def check_permissions
    authorize! :manage, @users
  end

  def check_update_permissions
    authorize! :update, User
  end

  def render_csv format
    format.csv { send_data(render_to_string(csv: @unpaginated_users), disposition: "attachment; filename=#{User.filename @utype}.csv") }
  end
end
