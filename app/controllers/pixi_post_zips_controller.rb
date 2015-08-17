class PixiPostZipsController < ApplicationController
  #before_filter :authenticate_user!
  autocomplete :pixi_post_zip, :zip, :full => true
  respond_to :html, :js, :json, :mobile

  def check
  end

  def submit
    @zip = PixiPostZip.find_by_zip params[:zip]
    if @zip
      redirect_to new_pixi_post_path(zip: params[:zip])
    else
      flash[:error] = PIXI_POST_ZIP_ERROR
      redirect_to check_pixi_post_zips_path
    end
  end

  private

  # parse results for active items only
  def get_autocomplete_items(parameters)
    super(parameters).active rescue nil
  end
end
