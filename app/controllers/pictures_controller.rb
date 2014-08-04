class PicturesController < ApplicationController
  before_filter :authenticate_user!, only: [:create, :destroy]
  respond_to :html, :json

  def asset
    @picture = Picture.find(params[:id])
    send_file file_name(@picture), type: @picture.photo_content_type, disposition: 'inline'
  end

  def display
    @picture = Picture.find(params[:id])
    redirect_to @picture.photo.url if Rails.env.development? || Rails.env.test?
  end

  def show
    @picture = Picture.find(params[:id])
    respond_with(@picture) do |format|
      format.html { render nothing: true }
      format.json { render json: {picture: @picture} }
    end
  end

  def create
    respond_to do |format|
      format.json { render nothing: true }
    end
  end

  def destroy
    @listing = TempListing.find_by_pixi_id params[:pixi_id]
    if @listing.delete_photo(params[:id])
      flash.now[:notice] = "Successfully removed image."
      @listing = TempListing.find_by_pixi_id params[:pixi_id]
    end
  end

  private

  def style
    params[:style].gsub!(/\.\./, '')
    params[:style].intern
  end

  def file_name pic
    pic.photo.exists? ? pic.photo.path(style) : pic.picture_from_url
  end
end
