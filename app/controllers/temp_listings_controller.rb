require 'will_paginate/array' 
class TempListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:unposted]
  before_filter :set_params, only: [:create, :update]
  autocomplete :site, :name, :full => true
  include ResetDate
  respond_to :html, :json, :js

  def new
    @listing = TempListing.new
    @photo = @listing.pictures.build
  end

  def show
    @listing = TempListing.find_by_pixi_id params[:id]
    @photo = @listing.pictures
  end

  def edit
    @listing = Listing.find_by_pixi_id(params[:id]).dup_pixi(false)
    @photo = @listing.pictures.build
  end

  def update
    @listing = TempListing.find_by_pixi_id params[:id]
    @listing.update_attributes params[:temp_listing]
    respond_with(@listing)
  end

  def create
    @listing = TempListing.new params[:temp_listing]
    @listing.save 
    respond_with(@listing)
  end

  def submit
    @listing = TempListing.find_by_pixi_id params[:id]
    unless @listing.resubmit_order 
      render action: :show, error: "Pixi was not submitted."
    end
  end

  def resubmit
    @listing = TempListing.find_by_pixi_id params[:id]
    if @listing.resubmit_order
      redirect_to listings_path
    else
      render action: :show, error: "Pixi was not resubmitted."
    end
  end

  def destroy
    @listing = TempListing.find_by_pixi_id params[:id]
    if @listing.destroy  
      redirect_to listings_path
    else
      respond_with @listing
    end
  end

  def unposted
    @listings = @user.new_pixis.paginate(page: @page)
  end
  
  private

  def load_data
    @page = params[:page] || 1
  end

  def set_params
    params[:temp_listing] = ResetDate::reset_dates(params[:temp_listing])
  end

  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active
  end

end
