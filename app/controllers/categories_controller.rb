require 'will_paginate/array' 
class CategoriesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:index, :category_type, :autocomplete_site_name, :location]
  before_filter :authenticate_user!, except: [:index, :autocomplete_site_name, :location, :category_type]
  before_filter :get_page, only: [:index, :inactive, :manage, :create, :update, :location]
  before_filter :set_status, only: [:manage, :inactive, :new]
  before_filter :load_list, only: [:index], if: Proc.new {|c| c.request.format.json? }
  before_filter :load_data, only: [:index, :location], unless: Proc.new {|c| c.request.format.json? }
  before_filter :load_page, only: [:index, :location, :manage], unless: Proc.new {|c| c.request.format.json? }
  before_filter :load_category, only: [:edit, :show, :category_type, :update]
  autocomplete :site, :name, :extra_data => [:site_type_code, :url], :full => true, :limit => 20
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

  def index
    respond_to do |format|
      format.html { @categories.paginate(page: @page, per_page: 20) }
      format.js { @categories.paginate(page: @page, per_page: 20) }
      format.json { render json: {categories: @categories } } 
    end
  end

  def manage
    respond_with(@categories.paginate(page: @page, per_page: 20))
  end

  def inactive
    @categories = Category.inactive.paginate page: @page, per_page: 20
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

  def set_status
    @status = params[:status]
  end

  # set location var
  def load_data
    @loc, @loc_name = LocationManager::setup request.remote_ip, params[:loc], params[:loc_name], @user.home_zip
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    super(parameters).active rescue nil
  end

  # load categories
  def load_page
    @categories = Category.active(true)
  end

  # load category
  def load_category
    @category = Category.find params[:id] rescue nil
  end

  # load categories
  def load_list
    uid = params['uid'] 
    @categories = uid.nil? ? Category.with_items(params[:loc], params[:utype]) : Category.user_with_items(User.find(uid))
  end
end
