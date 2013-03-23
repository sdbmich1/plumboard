class ListingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json, :js

  def index
    @listings = Listing.active
  end

  def show
    @listing = Listing.find_by_pixi_id params[:id]
    @photo = @listing.pictures
  end

  def destroy
    @listing = Listing.find_by_pixi_id params[:id]
    flash[:notice] = 'Successfully removed pixi.' if @listing.destroy 
    respond_with @listing
  end

  def seller
    @listings = @user.listings
    @temp_listings = @user.temp_listings
  end
end
