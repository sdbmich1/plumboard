require 'will_paginate/array' 
class TempListingsController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create, :autocomplete_site_name]
  before_filter :check_permissions, only: [:show, :edit, :update, :delete]
  before_filter :load_data, only: [:new, :edit, :index, :create, :unposted, :pending]
  before_filter :set_params, only: [:create, :update]
  before_filter :load_pixi, only: [:show, :update, :destroy, :submit]
  after_filter :set_uid, only: [:create]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  autocomplete :user, :business_name, :extra_data => [:business_name], :display_value => :pic_with_business_name
  autocomplete :site, :name, :full => true, :limit => 20
  include ResetDate, ControllerManager
  respond_to :html, :json, :js, :mobile, :csv
  layout :page_layout

  def index
    @listing.index_listings
  end

  def new
    respond_with(@listing.new_listing)
  end

  def show
    respond_with(@listing) do |format|
      format.json { render json: {listing: @listing} }
    end
  end

  def edit
    respond_with(@listing.edit_listing) do |format|
      format.json { render json: {listing: @listing.edit_listing} }
    end
  end

  def update
    @listing.pictures.build.photo = File.new params[:file].tempfile if params[:file]
    respond_with(@listing) do |format|
      if @listing.update_attributes(params[:temp_listing])
        format.json { render json: {listing: @listing} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def create
    @listing = TempListing.add_listing params[:temp_listing], @user
    @listing.pictures.build.photo = File.new params[:file].tempfile if params[:file]
    respond_with(@listing) do |format|
      if @listing.save
        flash[:notice] = 'Your pixi has been saved as a draft'
        format.json { render json: {listing: @listing} }
      else
        format.html { render :new }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def submit
    respond_with(@listing) do |format|
      if @listing.resubmit_order
        format.json { render json: {listing: @listing} }
      else
        format.html { redirect_to @listing, alert: "Pixi was not submitted. Please try again." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    respond_with(@listing) do |format|
      if @listing.destroy  
        format.html { redirect_to get_root_path }
	format.json { head :ok }
      else
        format.html { render action: :show, error: "Pixi was not removed. Please try again." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def unposted
    render_items 'TempListing', @listing, @listing.unposted_listings(@user)
  end

  def pending
    render_items 'TempListing', @listing, @listing.pending_listings(@user)
  end
  
  protected

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  # wrap query text for special characters
  def term
    Riddle::Query.escape params[:term]
  end  

  def load_data
    @listing = TempListingFacade.new(params)
    @listing.set_geo_data request, action_name, session[:home_id], @user
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
    super(parameters).active rescue nil
  end

  # check if pixipost to enable buyer autocomplete
  def has_pixan?
    !params[:pixan_id].blank?
  end

  def load_pixi
    @listing = TempListing.find_pixi params[:id]
  end

  def check_permissions
    authorize! :crud, TempListing
  end

  def set_uid
    ControllerManager::set_uid session, @listing, 'seller_id'
  end
end
