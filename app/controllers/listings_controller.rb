class ListingsController < ApplicationController
  respond_to :html, :json

  def new
    @user = User.find params[:user_id]
    @listing = Listing.new
    @photo = @listing.pictures.build
  end

  def index
    @listings = Listing.active
  end

  def show
    @listing = Listing.find params[:id]
  end

  def edit
    @listing = Listing.find params[:id]
    @photo = @listing.pictures.build
  end

  def update
    @listing = Listing.find params[:id]
    flash[:notice] = 'Successfully updated listing.' if @listing.update_attributes(params[:listing])
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
    #respond_with @listing
  end

  def destroy
    @listing = Listing.find params[:id]
    @listing.destroy 
    respond_with @listing
  end
end
