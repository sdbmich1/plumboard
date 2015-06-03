require 'will_paginate/array' 
class CategoriesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:index, :category_type, :autocomplete_site_name, :location]
  before_filter :authenticate_user!, except: [:index, :autocomplete_site_name, :location, :category_type]
  before_filter :load_data, only: [:index, :location]
  before_filter :check_signin_status, only: [:index]
  before_filter :load_page, only: [:index, :location, :manage]
  before_filter :load_category, only: [:edit, :show, :category_type, :update]
  before_filter :get_page, only: [:index, :inactive, :manage, :create, :update, :location]
  autocomplete :site, :name, :full => true, :limit => 20
  include LocationManager
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def new
    @category = Category.new
  end

  def edit
    respond_with(@category)
  end

  def create
    @category = Category.new params[:category]
    if @category.save 
      redirect_to manage_categories_path, notice: 'Successfully updated category'
    else
      render :new
    end
  end

  def update
    if @category.update_attributes(params[:category])
      redirect_to manage_categories_path, notice: 'Successfully updated category'
    else
      render :edit
    end
  end

  def inactive
    @categories = Category.inactive.paginate page: @page
  end

  def category_type
    respond_with(@category)
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
    @loc, @loc_name = LocationManager::setup request.remote_ip, params[:loc], params[:loc_name], @user.home_zip
  end

  # check user signin status
  def check_signin_status
    @newFlg = params[:newFlg].to_bool rescue nil
    flash.now[:success] = FB_WELCOME_MSG if @newFlg && @user.fb_user && @user.new_user? 
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    super(parameters).active rescue nil
  end

  # load categories
  def load_page
    respond_with(@categories = Category.active(true).paginate(page: @page, per_page: 60))
  end

  # load category
  def load_category
    @category = Category.find params[:id] rescue nil
  end
end
