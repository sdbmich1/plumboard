require 'will_paginate/array' 
class ListingsController < ApplicationController
  include PointManager, LocationManager, NameParse, ResetDate
  before_filter :authenticate_user!, except: [:local, :category, :show]
  before_filter :load_data, only: [:index, :seller, :category, :show, :local, :invoiced, :wanted]
  before_filter :load_pixi, only: [:show, :pixi_price, :repost, :update]
  before_filter :load_city, only: [:local, :category]
  after_filter :add_points, :set_session, only: [:show]
  respond_to :html, :json, :js, :mobile, :csv
  layout :page_layout

  def index
    @unpaginated_listings = Listing.check_category_and_location(@status, @cat, @loc)
    respond_with(@listings = @unpaginated_listings.paginate(page: @page, per_page: 15)) { |format| render_csv format }
  end

  def show
    load_comments
    respond_with(@listing) do |format|
      format.json { render json: {listing: @listing, comments: @comments} }
    end
  end

  def update
    if @listing.update_attributes(explanation: params[:reason], status: 'removed')
      redirect_to get_root_path
    else
      render action: :show, error: "Pixi was not removed. Please try again."
    end
  end

  def seller
    respond_with(@listings = Listing.get_by_status(@status).paginate(page: @page))
  end

  def seller_wanted
    respond_with(@listings = Listing.wanted_list(@user, nil, nil, false).paginate(page: @page))
  end

  def wanted
    @unpaginated_listings = Listing.wanted_list(@user, @cat, @loc)
    respond_with(@listings = @unpaginated_listings.paginate(page: @page, per_page: 15)) { |format| render_csv format }
  end

  def purchased
    respond_with(@listings = Listing.purchased(@user).paginate(page: @page))
  end

  def category
    respond_with(@listings)
  end

  def local
    respond_with(@listings)
  end

  def pixi_price
    respond_with(@listing)
  end

  def invoiced
    @unpaginated_listings = Listing.check_invoiced_category_and_location(@cat, @loc)
    respond_with(@listings = @unpaginated_listings.paginate(page: @page, per_page: 15)) { |format| render_csv format }
  end

  def repost
    if @listing && @listing.repost
      redirect_to get_root_path
    else
      render :show, notice: "Repost was not successful."
    end
  end

  protected

  def load_data
    @page, @cat, @loc, @loc_name = params[:page] || 1, params[:cid], params[:loc], params[:loc_name]
    @adminFlg = params[:adminFlg].to_bool rescue false
    @status = NameParse::transliterate params[:status] if params[:status]
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
    @category = Category.find @cat rescue nil if action_name == 'category'
    @listings = Listing.get_by_city(@cat, @loc).set_page @page
  end

  def set_session
    session[:back_to] = request.path unless signed_in?
  end

  def render_csv format
    format.csv { send_data(render_to_string(csv: @unpaginated_listings), disposition: "attachment; filename=#{Listing.filename @status}.csv") }
  end
end
