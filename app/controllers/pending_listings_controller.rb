class PendingListingsController < ApplicationController
  require 'will_paginate/array' 
  before_filter :authenticate_user!
  respond_to :html, :json, :js

  def index
    @listings = TempListing.get_by_status('pending')
    @listings.paginate(:page => params[:pending_page], :per_page => 30)
  end

  def show
    @listing = TempListing.find params[:id]
    @photo = @listing.pictures
  end

  def approve
    @listing = TempListing.find params[:id]
    if @listing.approve_order @user
      redirect_to pending_listings_path
    else
      render action: :show, error: "Order approval was not successful."
    end
  end

  def deny
    @listing = TempListing.find params[:id]
    if @listing.deny_order @user
      redirect_to pending_listings_path
    else
      render action: :show, error: "Order denial was not successful."
    end
  end
end
