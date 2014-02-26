require 'will_paginate/array' 
class CategoriesController < ApplicationController
  before_filter :check_permissions, only: [:new, :edit, :manage, :create, :destroy, :update]
  before_filter :authenticate_user!, only: [:new, :edit, :manage, :create, :destroy, :update]
  before_filter :load_data, only: [:index]
  before_filter :get_page, only: [:index, :inactive, :manage, :create, :update]
  autocomplete :site, :name, :full => true
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def index
    respond_with(@categories = Category.active.paginate(page: @page, per_page: 60))
  end

  def manage
    respond_with(@categories = Category.active.paginate(page: @page, per_page: 50))
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
    %w(index manage inactive).detect {|x| action_name == x} ? 'listings' : 'application'
  end

  def get_page
    @page = params[:page] || 1
  end

  # set location var
  def load_data
    @loc = params[:loc]
    @loc_name = Site.find @loc rescue nil
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active rescue items
  end

  def check_permissions
    authorize! :manage, @category 
    authorize! :manage, @categories
  end
end
