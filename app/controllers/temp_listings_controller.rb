class TempListingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json, :js

  def new
    @listing = TempListing.new
    @photo = @listing.pictures.build
  end

  def show
    @listing = TempListing.find params[:id]
    @photo = @listing.pictures
  end

  def edit
    @listing = TempListing.find params[:id]
    @photo = @listing.pictures.build
  end

  def update
    @listing = TempListing.find params[:id]
    @listing.update_attributes(params[:temp_listing])
    respond_with(@listing)
  end

  def create
    @listing = TempListing.new params[:temp_listing]
    @listing.save 
    respond_with(@listing)
  end

  def destroy
    @listing = TempListing.find params[:id]
    flash[:notice] = 'Successfully removed pixi.' if @listing.destroy 
    redirect_to listings_path
  end
end
