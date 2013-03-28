class PendingListingsController < ApplicationController
  require 'will_paginate/array' 
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  respond_to :html, :json, :js

  def index
    @listings = TempListing.get_by_status('pending')
    @listings.paginate(page: @page)
  end

  def show
    @listing = TempListing.find_by_pixi_id params[:id]
    @photo = @listing.pictures
  end

  def approve
    @listing = TempListing.find_by_pixi_id params[:id]
    if @listing.approve_order @user
      redirect_to pending_listings_path
    else
      render action: :show, error: "Order approval was not successful."
    end
  end

  def deny
    @listing = TempListing.find_by_pixi_id params[:id]
    if @listing.deny_order @user
      redirect_to pending_listings_path
    else
      render action: :show, error: "Order denial was not successful."
    end
  end

  protected

  def load_data
    @page = params[:pending_page] || 1
  end
end
