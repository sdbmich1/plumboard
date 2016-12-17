require 'will_paginate/array' 
class ListingsController < ApplicationController
  before_filter :authenticate_user!, except: [:local, :category, :show, :biz, :mbr, :career, :pub, :edu, :loc]
  before_filter :load_data, except: [:pixi_price, :repost, :update]
  before_filter :load_pixi, only: [:pixi_price, :repost, :update]
  before_filter :load_segment, only: [:local, :category], if: Proc.new {|c| c.request.format.json? }
  before_filter :load_city, only: [:local, :category], unless: Proc.new {|c| c.request.format.json? }
  before_filter :load_url_data, only: [:biz, :mbr, :career, :pub, :edu, :loc]
  after_filter :set_location, only: [:biz, :mbr, :pub, :edu, :loc]
  after_filter :add_points, only: [:show, :biz, :mbr, :pub, :edu, :loc]
  respond_to :html, :json, :js, :mobile, :csv
  layout :page_layout

  def index
    render_items 'Listing', @listing, @listing.index_listings
  end

  def show
    respond_with(@listing) do |format|
      format.json { render json: {listing: @listing.listing, comments: @listing.comments} }
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
    respond_with(@listing.seller_listings(@user))
  end

  def seller_wanted
    respond_with(@listing.seller_wanted_listings(@user))
  end

  def wanted
    render_items 'Listing', @listing, @listing.wanted_listings
  end

  def purchased
    respond_with(@listing.purchased_listings(@user))
  end

  def category
    render_json
  end

  def local
    render_json
  end

  def pixi_price
    respond_with(@listing)
  end

  def invoiced
    render_items 'Listing', @listing, @listing.invoiced_listings
  end

  def repost
    if @listing && @listing.repost
      redirect_to seller_listings_path(status: 'expired', adminFlg: params[:adminFlg])
    else
      render :show, notice: "Repost was not successful."
    end
  end

  def career
    respond_with(@listing)
  end

  def biz
    render_json
  end

  def mbr
    render_json
  end

  def pub
    render_json
  end

  def edu
    render_json
  end

  def loc
    render_json
  end

  protected

  def load_data
    @listing = ListingFacade.new(params, num_rows)
    @listing.set_geo_data request, action_name, session[:home_id], @user
  end

  def page_layout
    @listing.page_layout
  end

  def add_points
    @listing.add_points(@user) if signed_in?
  end

  def load_pixi
    @listing = Listing.find_pixi params[:id]
  end

  def load_city
    @listing.board_listings
  end

  def load_segment
    @listing.nearby_listings 
  end

  def load_url_data
    @listing.url_listings request, action_name, session[:home_id], @user
  end

  def set_location
    session[:back_to] = request.fullpath.split('?')[0] rescue nil
  end

  def render_json
    respond_with(@listing) do |format|
      format.json { render json: {listings: @listing.listings, categories: @listing.categories, sellers: @listing.sellers } }
    end
  end
end
