require 'will_paginate/array' 
class PendingListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, :check_permissions, only: [:index]
  respond_to :html, :json, :js

  def index
    @listings = TempListing.get_by_status(params[:status]).paginate(page: @page)
  end

  def show
    @listing = TempListing.find_pixi params[:id]
    @photo = @listing.pictures if @listing
  end

  def approve
    @listing = TempListing.find_pixi params[:id]
    if @listing && @listing.approve_order(@user)
      redirect_to pending_listings_path(status: 'pending')
    else
      flash[:error] = "Order approval was not successful."
      redirect_to pending_listing_path(@listing) if @listing
    end
  end

  def deny
    @listing = TempListing.find_pixi params[:id]
    if @listing && @listing.deny_order(@user, params[:reason])
      redirect_to pending_listings_path(status: 'pending')
    else
      flash[:error] = "Order denial was not successful."
      redirect_to pending_listing_path(@listing)
    end
  end

  protected

  def load_data
    @page = params[:page] || 1
  end

  def check_permissions
    authorize! :access, '/pending_listings' 
  end

  def check_access
    authorize! [:read, :update], @listing 
  end
end
