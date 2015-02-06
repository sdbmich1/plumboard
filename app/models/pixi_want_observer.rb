class PixiWantObserver < ActiveRecord::Observer
  observe PixiWant
  include PointManager

  def after_create model
    # send notice to recipient
      UserMailer.delay.send_interest(model) if model.listing

    # reset saved pixi status
    SavedListing.update_status_by_user model.user_id, model.pixi_id, 'wanted'

    # update points
    PointManager::add_points model.user, 'cs' if model.user
  end
end
