require 'will_paginate/array' 
class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_permissions, only: [:index], unless: Proc.new {|c| c.request.format.json? }
  before_filter :set_params, only: [:index]
  before_filter :load_data, only: [:index]
  before_filter :load_target, :check_update_permissions, only: [:update]
  before_filter :get_user, only: [:show, :edit, :update]
  respond_to :html, :js, :json, :mobile, :csv

  def index
    render_items 'User', @users.first, @users, 'user_type_code'
  end

  def show
  end

  def edit
  end

  def update
    respond_with(@usr) do |format|
      if @usr.update_attributes(params[:user])
        check_profile
	format.html { redirect_path }
	format.js { redirect_path }
      else
	format.html { render :new }
	format.json { render :json => { :errors => @usr.errors.full_messages }, :status => 422 }
      end
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
  
  def check_profile
    changing_email = params[:user][:email] != @usr.email
    if is_profile?  
      flash[:notice] = 'Saved changes successfully'
    else 
      flash.now[:notice] = flash_msg changing_email
      get_user
    end
  end

  # loads confirmation message
  def flash_msg chg_email
    if chg_email 
      (@usr.pending_reconfirmation?) ? t("devise.registrations.update_needs_confirmation") : t("devise.registrations.updated")
    else 
      'Saved changes successfully.'
    end
  end

  def query
    @query = Riddle::Query.escape params[:search]
  end 

  def set_params
    @utype, @page = params[:utype], params[:page] || 1
  end 

  def load_data
    list = params[:zip] ? User.get_nearest_stores(params[:zip], params[:miles]) : User.include_list.get_by_type(@utype)
    @users = list.paginate(page: @page, per_page: 15)
  end 

  def get_user
    @usr = User.find params[:id]
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    super(parameters).active rescue nil
  end

  def is_profile?
    !@target.match(/form|contact|details/).nil?
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

  def redirect_path
    @usr.is_business? && !@usr.has_address? ? redirect_to(settings_contact_path) : redirect_to(@usr)
  end
end
