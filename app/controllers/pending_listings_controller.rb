require 'will_paginate/array' 
class PendingListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, :check_permissions, only: [:index]
  respond_to :html, :json, :js

  def index
    @listings = TempListing.get_by_status('pending').paginate(page: @page)
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
    if @listing.deny_order @user, params[:reason]
      redirect_to pending_listings_path
    else
      render action: :show, error: "Order denial was not successful."
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
