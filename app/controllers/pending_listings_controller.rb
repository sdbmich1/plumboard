require 'will_paginate/array' 
class PendingListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, :check_permissions, only: [:index]
  before_filter :load_pixi, only: [:show, :approve, :deny]
  respond_to :html, :json, :js

  def index
    @listings = TempListing.get_by_status(params[:status]).paginate(page: @page)
  end

  def show
  end

  def approve
    if @listing && @listing.approve_order(@user)
      redirect_to pending_listings_path(status: 'pending')
    else
      render :show, notice: "Order approval was not successful."
    end
  end

  def deny
    if @listing && @listing.deny_order(@user, params[:reason])
      redirect_to pending_listings_path(status: 'pending')
    else
      render :show, notice: "Order denial was not successful."
    end
  end

  protected

  def load_data
    @page = params[:page] || 1
  end

  def load_pixi
    @listing = TempListing.find_pixi params[:id]
  end

  def check_permissions
    authorize! :access, '/pending_listings' 
  end

  def check_access
    authorize! [:read, :update], @listing 
  end
end
