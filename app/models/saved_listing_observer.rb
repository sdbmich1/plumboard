class SavedListingObserver < ActiveRecord::Observer
  observe SavedListing
  include PointManager

  def after_create model
    # send notice to recipient
    if (!model.listing.nil?)
      UserMailer.send_save_pixi(model).deliver_later
    end
    # reset saved pixi status
    # SavedListing.update_status_by_user model.user_id, model.pixi_id, 'saved'

    # update points
    PointManager::add_points model.user, 'spr' if model.user
  end
end
