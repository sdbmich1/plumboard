require 'will_paginate/array' 
class ListingsController < ApplicationController
  include PointManager, NameParse, ResetDate, LocationManager, ControllerManager
  before_filter :authenticate_user!, except: [:local, :category, :show, :biz, :mbr, :career, :pub, :edu, :loc]
  before_filter :load_data, except: [:pixi_price, :repost, :update, :biz, :mbr, :pub, :edu, :loc]
  before_filter :load_pixi, only: [:show, :pixi_price, :repost, :update]
  before_filter :load_job, only: [:career]
  before_filter :pxb_url, only: [:biz, :mbr, :pub, :edu, :loc] 
  before_filter :load_city, only: [:local, :category]
  before_filter :load_url_data, only: [:biz, :mbr, :career, :pub, :edu, :loc]
  after_filter :set_session, only: [:show]
  after_filter :set_location, only: [:biz, :mbr, :pub, :edu, :loc]
  after_filter :add_points, only: [:show, :biz, :mbr, :pub, :edu, :loc]
  respond_to :html, :json, :js, :mobile, :csv
  layout :page_layout

  def index
    @unpaginated_listings = Listing.check_category_and_location(@status, @cat, @loc, is_active?)
    respond_with(@listings = @unpaginated_listings.paginate(page: params[:page], per_page: 15), style: status) { |format| render_csv format }
  end

  def show
    @comments = @listing.comments.paginate(page: params[:page], per_page: PIXI_COMMENTS) rescue nil
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
    respond_with(@listings = Listing.get_by_status_and_seller(@status, @user, @adminFlg).paginate(page: params[:page], per_page: 15))
  end

  def seller_wanted
    respond_with(@listings = Listing.wanted_list(@user, nil, nil, false).paginate(page: params[:page], per_page: 15))
  end

  def wanted
    @unpaginated_listings = Listing.wanted_list(@user, @cat, @loc)
    respond_with(@listings = @unpaginated_listings.paginate(page: params[:page], per_page: 15)) { |format| render_csv format }
  end

  def purchased
    respond_with(@listings = Listing.purchased(@user).paginate(page: params[:page], per_page: 15))
  end

  def category
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings, sellers: @sellers} }
    end
  end

  def local
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings, sellers: @sellers} }
    end
  end

  def pixi_price
    respond_with(@listing)
  end

  def invoiced
    @unpaginated_listings = Listing.check_invoiced_category_and_location(@cat, @loc)
    respond_with(@listings = @unpaginated_listings.paginate(page: params[:page], per_page: 15)) { |format| render_csv format }
  end

  def repost
    if @listing && @listing.repost
      redirect_to seller_listings_path(status: 'expired', adminFlg: params[:adminFlg])
    else
      render :show, notice: "Repost was not successful."
    end
  end

  def career
    respond_with(@listings)
  end

  def biz
  end

  def mbr
  end

  def pub
  end

  def edu
  end

  def loc
  end

  protected

  def load_data
    @cat, @loc, @loc_name = params[:cid], params[:loc], params[:loc_name]
    @adminFlg = params[:adminFlg].to_bool rescue false
    @status = NameParse::transliterate params[:status] if params[:status]
    @loc, @loc_name = LocationManager::setup request.remote_ip, @loc || @region, @loc_name, @user.home_zip
  end

  def page_layout
    ControllerManager.render_board?(action_name) ? 'listings' : mobile_device? ? 'form' : action_name == 'show' ? 'pixi' : 'application'
  end

  def add_points
    PointManager::add_points @user, 'vpx' if signed_in?
  end

  def load_pixi
    @listing = Listing.find_pixi params[:id]
  end

  def load_city
    items = Listing.load_board(@cat, @loc)
    load_sellers items
  end

  def load_job
    params[:url] = 'Pixiboard'
    @cat = Category.get_by_name('Jobs') 
  end

  def pxb_url
    @url = ControllerManager::parse_url request
  end

  def load_url_data
    items = Listing.get_by_url(@url, action_name)
    load_sellers items
  end

  def load_sellers items
    @sellers = User.get_sellers(items) unless ControllerManager.private_url?(action_name)
    @listings = items.set_page params[:page] rescue nil
  end

  def set_location
    session[:back_to] = request.fullpath.split('?')[0] rescue nil
  end

  def status
    @status.to_sym rescue :active
  end

  def is_active?
    @status == 'active'
  end

  def render_csv format
    format.csv { send_data(render_to_string(csv: @unpaginated_listings, style: @status), disposition: 
      "attachment; filename=#{Listing.filename @status}.csv") }
  end
end
