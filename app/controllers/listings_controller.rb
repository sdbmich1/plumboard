require 'will_paginate/array' 
class ListingsController < ApplicationController
  include PointManager, LocationManager, NameParse, ResetDate
  before_filter :authenticate_user!, except: [:local, :category, :show]
  before_filter :load_data, except: [:pixi_price, :repost, :update]
  before_filter :load_pixi, only: [:show, :pixi_price, :repost, :update]
  before_filter :load_city, only: [:local, :category]
  before_filter :load_job, only: [:career]
  before_filter :pxb_url, only: [:biz, :member] 
  before_filter :load_url_data, only: [:biz, :member, :career]
  after_filter :set_location, only: [:biz, :member]
  after_filter :add_points, only: [:show, :biz, :member]
  after_filter :set_session, :load_comments, only: [:show]
  respond_to :html, :json, :js, :mobile, :csv
  layout :page_layout

  def index
    @unpaginated_listings = Listing.check_category_and_location(@status, @cat, @loc, true)
    respond_with(@listings = @unpaginated_listings.paginate(page: @page, per_page: 15), style: status) { |format| render_csv format }
  end

  def show
    respond_with(@listing)
  end

  def update
    if @listing.update_attributes(explanation: params[:reason], status: 'removed')
      redirect_to get_root_path
    else
      render action: :show, error: "Pixi was not removed. Please try again."
    end
  end

  def seller
    respond_with(@listings = Listing.get_by_status_and_seller(@status, @user, @adminFlg).paginate(page: @page))
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

  def career
    respond_with(@listings)
  end

  def biz
    respond_with(@listings)
  end

  def member
    respond_with(@listings)
  end

  protected

  def load_data
    @page, @cat, @loc, @loc_name = params[:page] || 1, params[:cid], params[:loc], params[:loc_name]
    @adminFlg = params[:adminFlg].to_bool rescue false
    @status = NameParse::transliterate params[:status] if params[:status]
    @loc, @loc_name = LocationManager::setup request.remote_ip, @loc || @region, @loc_name, @user.home_zip
  end

  def page_layout
    %w(category local biz member career).detect {|x| action_name == x} ? 'listings' : mobile_device? ? 'form' : action_name == 'show' ? 'pixi' : 
      'application'
  end

  def add_points
    PointManager::add_points @user, 'vpx' if signed_in?
  end

  def load_comments
    @comments = @listing.comments.paginate(page: @page, per_page: PIXI_COMMENTS) rescue nil
  end

  def load_pixi
    @listing = Listing.find_pixi params[:id]
  end

  def load_city
    @category = Category.find @cat rescue nil if action_name == 'category'
    @listings = Listing.get_by_city(@cat, @loc).board_fields.set_page @page
    @sellers = User.get_sellers @cat, @loc
  end

  def load_job
    params[:url] = 'Pixiboard'
    @cat = Category.get_by_name('Jobs') 
  end

  def pxb_url
    @url = request.original_url.to_s.split('/')[4].split('?')[0] rescue nil
  end

  def load_url_data
    @listings = Listing.get_by_url(@url, @page)
  end

  def set_location
    session[:back_to] = request.fullpath
  end

  def status
    @status.to_sym
  end

  def render_csv format
    format.csv { send_data(render_to_string(csv: @unpaginated_listings, style: @status), disposition: "attachment; filename=#{Listing.filename @status}.csv") }
  end
end
