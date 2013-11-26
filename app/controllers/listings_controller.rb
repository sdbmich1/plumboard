require 'will_paginate/array' 
class ListingsController < ApplicationController
  include PointManager
  before_filter :authenticate_user!
  before_filter :get_location, only: [:index]
  before_filter :load_data, only: [:index, :seller, :category, :show, :location]
  after_filter :add_points, only: [:show]
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def index
    @listings = Listing.active_page(@ip, @page)
    @categories = Category.active

    respond_to do |format|
      format.mobile 
      format.html 
      format.json { render json: {user: @user, listings: @listings, categories: @categories} }
      format.js 
    end
  end

  def show
    @listing = Listing.find_by_pixi_id params[:id]
    @post = Post.new 
    @comment = @listing.comments.build if @listing
    load_comments

    respond_to do |format|
      format.mobile 
      format.html 
      format.json { render json: {user: @user, listing: @listing, comments: @comments} }
      format.js 
    end
  end

  def destroy
    @listing = Listing.find_by_pixi_id params[:id]
    flash[:notice] = 'Successfully removed pixi.' if @listing.destroy 
    respond_with @listing
  end

  def seller
    @listings = @user.pixis.paginate(page: @page)

    respond_to do |format|
      format.mobile { render :nothing => true }
      format.html { render :nothing => true }
      format.json { render json: {user: @user, listings: @listings} }
      format.js 
    end
  end

  def sold
    @listings = @user.sold_pixis.paginate(page: @page)

    respond_to do |format|
      format.mobile { render :nothing => true }
      format.html { render :nothing => true }
      format.json { render json: {user: @user, listings: @listings} }
      format.js 
    end
  end

  def category
    @listings = Listing.get_by_city @cat, @loc, @page
    @category = Category.find @cat

    respond_to do |format|
      format.mobile { render :nothing => true }
      format.html { render :nothing => true }
      format.json { render json: {user: @user, listings: @listings} }
      format.js 
    end
  end

  def location
    @listings = Listing.get_by_city @cat, @loc, @page

    respond_to do |format|
      format.mobile { render :nothing => true }
      format.html { render :nothing => true }
      format.json { render json: {user: @user, listings: @listings} }
      format.js 
    end
  end

  def loc_name
    @sites = Site.search query, star: true, :page => params[:page], :per_page => 10
    respond_to do |format|
      format.json { render json: @sites }
    end
  end

  protected

  def load_data
    @page = params[:page] || 1
    @cat, @loc = params[:cid], params[:loc]
  end

  def page_layout
    %w(index category location).detect {|x| action_name == x} ? 'listings' : mobile_device? ? 'form' : 'application'
  end

  def add_points
    PointManager::add_points @user, 'vpx'
  end

  def load_comments
    @comments = @listing.comments.paginate(page: @page, per_page: params[:per_page] || 4) if @listing
  end

  def get_location
    @ip = Rails.env.development? || Rails.env.test? ? request.remote_ip : request.ip
  end

  def query
    @query = Riddle::Query.escape params[:search]
  end 
end
