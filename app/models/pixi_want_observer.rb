class PixiWantObserver < ActiveRecord::Observer
  observe PixiWant
  include PointManager

  def after_create model
    # send notice to recipient
    UserMailer.delay.send_interest(model)

    # update points
    PointManager::add_points model.user, 'cs' if model.user
  end
end
