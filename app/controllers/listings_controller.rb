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
    respond_with(@listings) do |format|
      format.json { render json: {user: @user, listings: @listings, categories: @categories} }
    end
  end

  def show
    @listing = Listing.find_by_pixi_id params[:id]
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
        format.html { redirect_to listings_path, notice: 'Successfully removed pixi.' }
	format.json { head :ok }
      else
        format.html { render action: :show, error: "Pixi was not removed." }
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

  def location
    @listings = Listing.get_by_city @cat, @loc, @page
    respond_to do |format|
      format.html {}
      format.mobile {}
      format.js {}
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
end
