require 'will_paginate/array' 
class ListingsController < ApplicationController
  include PointManager, LocationManager
  before_filter :authenticate_user!, except: [:local, :category]
  before_filter :load_data, only: [:index, :seller, :category, :show, :local]
  before_filter :load_pixi, only: [:destroy, :pixi_price, :update]
  before_filter :load_city, only: [:local, :category]
  after_filter :add_points, only: [:show]
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def index
    respond_with(@listings = Listing.active_without_job_type.paginate(page: @page, per_page: 15))
  end

  def show
    @listing = Listing.find_pixi(params[:id])
    load_comments
    respond_with(@listing) do |format|
      format.json { render json: {listing: @listing, comments: @comments} }
    end
  end

  def update
    if @listing.update_attributes(explanation: params[:reason], status: 'removed')
      redirect_to category_listings_path(loc: @listing.site_id, cid: @listing.category_id)
    else
      render action: :show, error: "Pixi was not removed. Please try again."
    end
  end

  def destroy
    respond_with(@listing) do |format|
      if @listing.destroy
        format.html { redirect_to get_root_path, notice: 'Successfully removed pixi.' }
        format.mobile { redirect_to get_root_path, notice: 'Successfully removed pixi.' }
	format.json { head :ok }
      else
        format.html { render action: :show, error: "Pixi was not removed." }
        format.mobile { render action: :show, error: "Pixi was not removed." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def seller
    respond_with(@listings = Listing.active_without_job_type.get_by_seller(@user, is_admin?).paginate(page: @page))
  end

  def sold
    respond_with(@listings = Listing.get_by_seller(@user, is_admin?).get_by_status('sold').paginate(page: @page))
  end

  def wanted
    respond_with(@listings = Listing.wanted_list(@user, @page))
  end

  def purchased
    respond_with(@listings = Listing.get_by_buyer(@user).get_by_status('sold').paginate(page: @page))
  end

  def category
    @category = Category.find @cat rescue nil
    respond_with(@listings)
  end

  def local
    respond_with(@listings)
  end

  def pixi_price
    @price = @listing.price rescue nil
    respond_with(@price)
  end

  protected

  def load_data
    @page, @cat, @loc, @loc_name = params[:page] || 1, params[:cid], params[:loc], params[:loc_name]
    @loc_name ||= LocationManager::get_loc_name(request.remote_ip, @loc || @region, @user.home_zip)
    @loc ||= LocationManager::get_loc_id(@loc_name, @user.home_zip)
  end

  def page_layout
    %w(category local).detect {|x| action_name == x} ? 'listings' : mobile_device? ? 'form' : action_name == 'show' ? 'pixi' : 
      'application'
  end

  def add_points
    PointManager::add_points @user, 'vpx' if signed_in?
  end

  def load_comments
    @comments = @listing.comments.paginate(page: @page, per_page: PIXI_COMMENTS) rescue nil
  end

  def load_pixi
    @listing = Listing.find_by_pixi_id params[:id]
  end

  def load_city
    @listings = Listing.get_by_city @cat, @loc, @page
  end
 
  def is_admin?
    @user.user_type_code == 'AD' rescue false
  end
end
