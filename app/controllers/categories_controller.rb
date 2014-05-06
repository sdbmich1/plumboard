require 'will_paginate/array' 
class CategoriesController < ApplicationController
  # load_and_authorize_resource
  # skip_authorize_resource :only => [:index, :category_type, :autocomplete_site_name]
  before_filter :check_permissions, only: [:edit, :show, :inactive, :manage, :create, :update]
  before_filter :authenticate_user!, except: [:index, :autocomplete_site_name]
  before_filter :load_data, :check_signin_status, only: [:index]
  before_filter :get_page, only: [:index, :inactive, :manage, :create, :update]
  autocomplete :site, :name, :full => true, :limit => 20
  include LocationManager
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def index
    respond_with(@categories = Category.active(true).paginate(page: @page, per_page: 60))
  end

  def manage
    respond_with(@categories = Category.active(true).paginate(page: @page, per_page: 60))
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
      flash[:notice] = 'Successfully created category.' 
      redirect_to manage_categories_path
    else
      render :new
    end
  end

  def update
    @category = Category.find params[:id]
    if @category.update_attributes(params[:category])
      flash[:notice] = 'Successfully updated category'
      redirect_to manage_categories_path
    else
      render :edit
    end
  end

  def inactive
    @categories = Category.inactive.paginate page: @page
  end

  def category_type
    @category = Category.find params[:id] if params[:id]
    @cat_type = @category.category_type rescue nil
    respond_with(@cat_type)
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
    if @newFlg && @user.fb_user && @user.new_user? 
      flash.now[:success] = FB_WELCOME_MSG
    end
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active rescue items
  end

  def check_permissions
    authorize! :manage, Category
  end
end
