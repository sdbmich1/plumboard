class ListingsController < ApplicationController
  require 'will_paginate/array' 
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :seller]
  respond_to :html, :json, :js
  layout :page_layout

  def index
    @listings = Listing.active
    @listings.paginate(:page => @page)
    respond_with @listings
  end

  def show
    @listing = Listing.find_by_pixi_id params[:id]
    @photo = @listing.pictures
  end

  def destroy
    @listing = Listing.find_by_pixi_id params[:id]
    flash[:notice] = 'Successfully removed pixi.' if @listing.destroy 
    respond_with @listing
  end

  def seller
    @listings = @user.listings.paginate(:page => @page)
    @temp_listings = @user.temp_listings
  end

  protected

  def page_layout
    %W(index seller).detect { |x| x == action_name } ? 'listings' : 'application'
  end

  def load_data
    @page = params[:page] || 1
  end
end
