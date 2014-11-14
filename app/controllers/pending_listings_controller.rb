require 'will_paginate/array' 
class PendingListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, :check_permissions, only: [:index]
  before_filter :load_pixi, only: [:show, :approve, :deny]
  respond_to :html, :json, :js, :csv

  def index
    respond_with(@listings = TempListing.check_category_and_location(@status, @cat, @loc, @page).paginate(page: @page, per_page: 15))
  end

  def show
    respond_with(@listing)
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
    @page, @cat, @loc, @loc_name = params[:page] || 1, params[:cid], params[:loc], params[:loc_name]
    @status = NameParse::transliterate params[:status] if params[:status]
    @loc_name ||= LocationManager::get_loc_name(request.remote_ip, @loc || @region, @user.home_zip)
    @loc ||= LocationManager::get_loc_id(@loc_name, @user.home_zip)
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
