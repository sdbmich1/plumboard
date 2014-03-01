require 'will_paginate/array' 
class ListingsController < ApplicationController
  include PointManager
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
    @like = @user.pixi_likes.find_by_pixi_id params[:id] rescue nil
    @saved = @user.saved_listings.find_by_pixi_id params[:id] rescue nil
    @contact = @user.posts.find_by_pixi_id params[:id] rescue nil
    @post = Post.new 
    @comment = @listing.comments.build if @listing
    load_comments
    respond_with(@listing) do |format|
      format.json { render json: {listing: @listing, comments: @comments} }
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

  # get pixi price
  def get_pixi_price
    @price = Listing.find_by_pixi_id(params[:pixi_id]).price
    respond_with(@price)
  end

  protected

  def load_data
    @ip = Rails.env.development? || Rails.env.test? ? '24.4.199.34' : request.remote_ip
    @page, @cat, @loc = params[:page] || 1, params[:cid], params[:loc]
    @loc_name = Site.find(@loc).name rescue nil
    @loc_name ||= Geocoder.search(@ip).first.city rescue nil
    Rails.logger.info "IP = " + @ip.to_s
  end

  def page_layout
    %w(index category local).detect {|x| action_name == x} ? 'listings' : mobile_device? ? 'form' : 'application'
  end

  def add_points
    PointManager::add_points @user, 'vpx'
  end

  def load_comments
    @comments = @listing.comments.paginate(page: @page, per_page: params[:per_page] || 4) if @listing
  end
end
