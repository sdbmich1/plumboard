require 'will_paginate/array' 
class ListingsController < ApplicationController
  include PointManager, LocationManager
  before_filter :authenticate_user!, except: [:local, :category]
  before_filter :load_data, only: [:index, :seller, :category, :show, :local]
  after_filter :add_points, only: [:show]
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def index
    @listings = Listing.active_page(@ip, @page)
    @categories = Category.active
    respond_with(@listings) do |format|
      format.json { render json: {user: @user, listings: @listings, categories: @categories} }
    end
  end

  def show
    @listing = Listing.find_by_pixi_id params[:id]
    load_comments
    respond_with(@listing) do |format|
      format.json { render json: {listing: @listing, comments: @comments} }
    end
  end

  def update
    @listing = Listing.find_by_pixi_id params[:id]
    if @listing.update_attributes(explanation: params[:reason], status: 'removed')
      redirect_to category_listings_path(loc: @listing.site_id, cid: @listing.category_id)
    else
      render action: :show, error: "Pixi was not removed. Please try again."
    end
  end

  def destroy
    @listing = Listing.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.destroy
        format.html { redirect_to root_path, notice: 'Successfully removed pixi.' }
        format.mobile { redirect_to root_path, notice: 'Successfully removed pixi.' }
	format.json { head :ok }
      else
        format.html { render action: :show, error: "Pixi was not removed." }
        format.mobile { render action: :show, error: "Pixi was not removed." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def seller
    @listings = @user.pixis.paginate(page: @page)
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def sold
    @listings = @user.sold_pixis.paginate(page: @page)
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def wanted
    @listings = Listing.wanted_list @user, @page
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def purchased
    @listings = @user.purchased_listings.paginate(page: @page)
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def category
    @listings = Listing.get_by_city @cat, @loc, @page
    @category = Category.find @cat
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def local
    @listings = Listing.get_by_city @cat, @loc, @page
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def pixi_price
    @listing = Listing.find_by_pixi_id(params[:pixi_id]) if params[:pixi_id]
    @price = @listing.price rescue nil
  end

  protected

  def load_data
    @page, @cat, @loc, @loc_name = params[:page] || 1, params[:cid], params[:loc], params[:loc_name]
    @loc_name ||= LocationManager::get_loc_name request.remote_ip, @loc, @user.home_zip
    @loc ||= LocationManager::get_loc_id(@loc_name, @user.home_zip)
  end

  def page_layout
    %w(index category local).detect {|x| action_name == x} ? 'listings' : mobile_device? ? 'form' : action_name == 'show' ? 'pixi' : 'application'
  end

  def add_points
    PointManager::add_points @user, 'vpx'
  end

  def load_comments
    @comments = @listing.comments.paginate(page: @page, per_page: PIXI_COMMENTS) rescue nil
  end
end
