class ListingObserver < ActiveRecord::Observer
  observe Listing
  include PointManager

  # update points
  def after_create model
    ptype = model.premium? ? 'app' : 'abp'
    PointManager::add_points model.user, ptype if model.user

    # remove temp pixi
    delete_temp_pixi model
  end

  # remove temp pixi
  def after_update model
    delete_temp_pixi model
  end

  def delete_temp_pixi model
    if listing = TempListing.where(:pixi_id => model.pixi_id).first
      listing.destroy
    end
  end
end
