class PicturesController < ApplicationController
  def asset
    @picture = Picture.find(params[:id])

    #check permissions before delivering asset
    send_file @picture.photo.path(style),
	                  :type => @picture.photo_content_type,
	                  :disposition => 'inline'
  end

  private

  def style
    params[:style].gsub!(/\.\./, '')
    params[:style].intern
  end
end
