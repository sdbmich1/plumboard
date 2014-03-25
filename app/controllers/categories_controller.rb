require 'will_paginate/array' 
class CategoriesController < ApplicationController
  # load_and_authorize_resource
  before_filter :check_permissions, only: [:edit, :show, :inactive, :manage, :create, :update]
  before_filter :authenticate_user!, only: [:edit, :show, :inactive, :manage, :create, :update]
  before_filter :load_data, :check_signin_status, only: [:index]
  before_filter :get_page, only: [:index, :inactive, :manage, :create, :update]
  autocomplete :site, :name, :full => true, :limit => 20
  include LocationManager
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def index
    respond_with(@categories = Category.active.paginate(page: @page, per_page: 60))
  end

  def manage
    respond_with(@categories = Category.active.paginate(page: @page, per_page: 60))
  end

  def new
    @category = Category.new
    @photo = @category.pictures.build
  end

  def edit
    @category = Category.find params[:id]
  end

  def show
    respond_with(@category = Category.find(params[:id]))
  end

  def create
    @category = Category.new params[:category]
    if @category.save 
      flash.now[:notice] = 'Successfully created category.' 
      @categories = Category.active.paginate page: @page
    end
  end

  def update
    @category = Category.find params[:id]
    if @category.update_attributes(params[:category])
      flash.now[:notice] = 'Successfully updated category'
      @categories = Category.active.paginate page: @page
    end
  end

  def inactive
    @categories = Category.inactive.paginate page: @page
  end

  protected

  def page_layout
    %w(index manage inactive).detect {|x| action_name == x} ? 'categories' : 'application'
  end

  def get_page
    @page = params[:page] || 1
  end

  # set location var
  def load_data
    @loc = params[:loc]
    @loc_name = LocationManager::get_loc_name request.remote_ip, @loc, @user.home_zip
    @loc ||= LocationManager::get_loc_id(@loc_name, @user.home_zip)
  end

  # check user signin status
  def check_signin_status
    @newFlg = params[:newFlg].to_bool rescue nil
    if @newFlg && @user.fb_user  
      msg = 'To get a better user experience, please go to My Settings and add your zip code. This will enable us to better localize your pixis.'
      flash.now[:success] = msg
    end
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active rescue items
  end

  def check_permissions
    authorize! :update, @category 
    authorize! :manage, @categories
  end
end
