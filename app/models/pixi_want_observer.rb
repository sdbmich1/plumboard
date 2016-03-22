class PixiWantObserver < ActiveRecord::Observer
  observe PixiWant
  include PointManager

  def after_create model
    # send notice to recipient
    UserMailer.send_interest(model).deliver_later if model.listing && !model.listing.buy_now_flg

    # reset saved pixi status
    SavedListing.update_status_by_user model.user_id, model.pixi_id, 'wanted'

    # update points
    PointManager::add_points model.user, 'cs' if model.user
  end
end
