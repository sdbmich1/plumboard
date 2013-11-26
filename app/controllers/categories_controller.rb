require 'will_paginate/array' 
class CategoriesController < ApplicationController
  before_filter :check_permissions, except: [:show, :index]
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  before_filter :get_page, only: [:index, :inactive, :manage, :create, :update]
  respond_to :html, :json, :js
  layout :page_layout

  def index
    respond_with(@categories = Category.active.paginate(page: @page, per_page: 50))
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
    (%w(new edit inactive).detect { |x| x == action_name }).nil? ? 'application' : 'listings'
  end

  def get_page
    @page = params[:page] || 1
  end

  # set location var
  def load_data
    @loc = params[:loc]
  end

  def check_permissions
    authorize! :manage, @category 
    authorize! :manage, @categories
  end
end
