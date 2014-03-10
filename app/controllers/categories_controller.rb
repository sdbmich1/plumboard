require 'will_paginate/array' 
class CategoriesController < ApplicationController
  # load_and_authorize_resource
  before_filter :check_permissions, only: [:edit, :show, :inactive, :manage, :create, :update]
  before_filter :authenticate_user!, only: [:edit, :show, :inactive, :manage, :create, :update]
  before_filter :load_data, only: [:index]
  before_filter :get_page, only: [:index, :inactive, :manage, :create, :update]
  autocomplete :site, :name, :full => true, :limit => 20
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
    if @loc.blank?
      @ip = Rails.env.development? || Rails.env.test? ? '24.4.199.34' : request.remote_ip
      @area = Geocoder.search(@ip)
      @loc_name = Contact.near([@area.first.latitude, @area.first.longitude]).first.city rescue nil
      @loc = Site.find_by_name(@loc_name).id rescue nil
    else
      @loc_name = Site.find(@loc).city rescue nil
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
