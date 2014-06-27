require 'will_paginate/array' 
class CategoriesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:index, :category_type, :autocomplete_site_name, :location]
  before_filter :authenticate_user!, except: [:index, :autocomplete_site_name, :location]
  before_filter :load_data, only: [:index, :location]
  before_filter :check_signin_status, only: [:index]
  before_filter :load_page, only: [:index, :location, :manage]
  before_filter :load_category, only: [:edit, :show, :category_type, :update]
  before_filter :get_page, only: [:index, :inactive, :manage, :create, :update]
  autocomplete :site, :name, :full => true, :limit => 20
  include LocationManager
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def new
    @category = Category.new
    @photo = @category.pictures.build
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
    @page, @loc, @loc_name = params[:page] || 1, params[:loc], params[:loc_name]
    @loc_name ||= LocationManager::get_loc_name request.remote_ip, @loc, @user.home_zip
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

  # load category
  def load_page
    respond_with(@categories = Category.active(true).paginate(page: @page, per_page: 60))
  end

  # load category
  def load_category
    @category = Category.find params[:id]
  end
end
