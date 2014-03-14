require 'will_paginate/array' 
class TempListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:unposted]
  before_filter :set_params, only: [:create, :update]
  autocomplete :site, :name, :full => true
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name, if: :has_pixan?
  include ResetDate
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def new
    @listing = TempListing.new pixan_id: params[:pixan_id]
    @photo = @listing.pictures.build
  end

  def show
    @listing = TempListing.find_by_pixi_id params[:id]
    @photo = @listing.pictures if @listing
    respond_with(@listing) do |format|
      format.json { render json: {listing: @listing} }
    end
  end

  def edit
    @listing = TempListing.find_by_pixi_id(params[:id]) || Listing.find_by_pixi_id(params[:id]).dup_pixi(false)
    @photo = @listing.pictures.build if @listing
    respond_with(@listing) do |format|
      format.json { render json: {listing: @listing} }
    end
  end

  def update
    @listing = TempListing.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.update_attributes(params[:temp_listing])
        format.json { render json: {listing: @listing} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def create
    @listing = TempListing.new params[:temp_listing]
    if params[:file]
      @pic = @listing.pictures.build
      @pic.photo = File.new params[:file].tempfile 
    end
    respond_with(@listing) do |format|
      if @listing.save
        format.json { render json: {listing: @listing} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def submit
    @listing = TempListing.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.resubmit_order
        format.json { render json: {listing: @listing} }
      else
        format.html { render action: :show, error: "Pixi was not submitted. Please try again." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def resubmit
    @listing = TempListing.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.resubmit_order
        format.json { render json: {listing: @listing} }
      else
        format.html { render action: :show, error: "Pixi was not submitted. Please try again." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @listing = TempListing.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.destroy  
        format.html { redirect_to root_path }
        format.mobile { redirect_to root_path }
	format.json { head :ok }
      else
        format.html { render action: :show, error: "Pixi was not removed. Please try again." }
        format.mobile { render action: :show, error: "Pixi was not removed. Please try again." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def unposted
    @listings = @user.new_pixis.paginate(page: @page)
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def pending
    @listings = @user.pending_pixis.paginate(page: @page)
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end
  
  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def load_data
    @page = params[:page] || 1
  end

  # parse fields to adjust formatting
  def set_params
    respond_to do |format|
      format.html { params[:temp_listing] = ResetDate::reset_dates(params[:temp_listing]) }
      format.json { params[:temp_listing] = JSON.parse(params[:temp_listing]) }
    end
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active rescue items
  end

  # check if pixipost to enable buyer autocomplete
  def has_pixan?
    !params[:pixan_id].blank?
  end

end
