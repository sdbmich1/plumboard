class ListingObserver < ActiveRecord::Observer
  observe Listing
  include PointManager

  # update points
  def after_create model
    ptype = model.premium? ? 'app' : 'abp'
    PointManager::add_points model.user, ptype 
  end

end
