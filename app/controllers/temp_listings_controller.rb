require 'will_paginate/array' 
class TempListingsController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create, :autocomplete_site_name]
  before_filter :check_permissions, only: [:show, :edit, :update, :delete]
  before_filter :load_data, only: [:index, :unposted, :pending]
  before_filter :set_params, only: [:create, :update]
  before_filter :load_pixi, only: [:edit, :show, :update, :destroy, :submit]
  before_filter :load_post_type, only: [:new, :edit]
  after_filter :set_uid, only: [:create]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  autocomplete :user, :business_name, :extra_data => [:business_name], :display_value => :pic_with_business_name
  autocomplete :site, :name, :full => true, :limit => 20
  include ResetDate
  respond_to :html, :json, :js, :mobile, :csv
  layout :page_layout

  def index
    respond_with(@listings = TempListing.check_category_and_location(@status, @cat, @loc, false).paginate(page: @page, per_page: 15))
  end

  def new
    respond_with(@listing = TempListing.new(site_id: params[:loc], pixan_id: params[:pixan_id]))
  end

  def show
    respond_with(@listing)
  end

  def edit
    respond_with(@listing ||= Listing.find_by_pixi_id(params[:id]).dup_pixi(false))
  end

  def update
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
    respond_with(@listing) do |format|
      if @listing.save
        flash[:notice] = 'Your pixi has been saved as a draft'
        format.json { render json: {listing: @listing} }
      else
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
        format.mobile { redirect_to get_root_path }
	format.json { head :ok }
      else
        format.html { render action: :show, error: "Pixi was not removed. Please try again." }
        format.mobile { render action: :show, error: "Pixi was not removed. Please try again." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def unposted
    respond_with(@listings = TempListing.draft.get_by_seller(@user, 'new|edit', @adminFlg).paginate(page: @page, per_page: 15))
  end

  def pending
    respond_with(@listings = TempListing.get_by_status('pending').get_by_seller(@user, 'pending', @adminFlg).paginate(page: @page, per_page: 15))
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
    @page, @cat, @loc, @loc_name = params[:page] || 1, params[:cid], params[:loc], params[:loc_name] 
    @adminFlg = params[:adminFlg].to_bool rescue false
    @status = NameParse::transliterate params[:status] if params[:status]
    @loc, @loc_name = LocationManager::setup request.remote_ip, @loc || @region, @loc_name, @user.home_zip
  end

  # parse fields to adjust formatting
  def set_params
    @listing.pictures.build.photo = File.new params[:file].tempfile if params[:file]
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

  def for_business?
    @ptype.upcase == 'BUS'
  end

  def load_pixi
    @listing = TempListing.find_by_pixi_id(params[:id])
  end

  def load_post_type
    @ptype = params[:ptype]
  end

  def check_permissions
    authorize! :crud, TempListing
  end

  def set_uid
    ControllerManager::set_uid session, @listing, 'seller_id'
  end
end
