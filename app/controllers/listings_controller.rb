require 'will_paginate/array' 
class ListingsController < ApplicationController
  include PointManager
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :seller, :category, :show, :location]
  after_filter :add_points, only: [:show]
  respond_to :html, :json, :js
  layout :page_layout

  def index
    @listings = Listing.active_page @page
  end

  def show
    @listing = Listing.find_by_pixi_id params[:id]
    @post = Post.new 
    @comment = @listing.comments.build
    load_comments
  end

  def destroy
    @listing = Listing.find_by_pixi_id params[:id]
    flash[:notice] = 'Successfully removed pixi.' if @listing.destroy 
    respond_with @listing
  end

  def seller
    @listings = @user.pixis.paginate(page: @page)
  end

  def sold
    @listings = @user.sold_pixis.paginate(page: @page)
  end

  def category
    @listings = Listing.get_category_by_site @category, params[:loc], @page
  end

  def location
    @listings = Listing.get_by_site params[:loc], @page
  end

  protected

  def page_layout
    %w(index category location).detect {|x| action_name == x} ? 'listings' : 'application'
  end

  def load_data
    @page = params[:page] || 1
    @category = params[:cid]
  end

  def add_points
    PointManager::add_points @user, 'vpx'
  end

  def load_comments
    @comments = @listing.comments.paginate(page: @page, per_page: params[:per_page] || 4)
  end

  def get_location
    @lat, @lng = request.location.latitude, request.location.longitude
  end
end
