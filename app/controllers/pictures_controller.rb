class PicturesController < ApplicationController
  before_filter :authenticate_user!, only: [:destroy]

  def asset
    @picture = Picture.find(params[:id])

    #check permissions before delivering asset
    send_file @picture.photo.path(style), type: @picture.photo_content_type, disposition: 'inline'
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
end
