class ListingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json, :js

  def index
    @listings = Listing.active
  end

  def show
    @listing = Listing.find params[:id]
    @photo = @listing.pictures
  end

  def edit
    @listing = Listing.find params[:id]
    @photo = @listing.pictures.build
  end

  def update
    @listing = Listing.find params[:id]
    flash[:notice] = 'Successfully updated pixi.' if @listing.update_attributes(params[:listing])
    respond_with(@listing)
  end

  def create
    @listing = Listing.new params[:listing]
    if @listing.save 
        redirect_to @listing, :notice  => "Pixi created successfully."
    else
        flash[:error] = @listing.errors
        render :action => 'new'
    end
  end

  def destroy
    @listing = Listing.find params[:id]
    flash[:notice] = 'Successfully removed pixi.' if @listing.destroy 
    respond_with @listing
  end

  def seller
    @user = User.find params[:user_id]
    @listings = @user.listings
    @temp_listings = @user.temp_listings
  end
end
