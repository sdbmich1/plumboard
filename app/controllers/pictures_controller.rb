class PicturesController < ApplicationController
  def asset
    picture = Picture.find(params[:id])
    params[:style].gsub!(/\.\./, '')

    #check permissions before delivering asset?
    send_file picture.photo.path(params[:style].intern),
	                  :type => picture.photo_content_type,
	                  :disposition => 'inline'
  end
end
