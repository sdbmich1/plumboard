class PostObserver < ActiveRecord::Observer
  observe Post
  include PointManager

  def after_create model
    # send notice to recipient
    UserMailer.delay.send_notice(model) unless model.system_msg? || model.want_msg? || model.ask_msg?

    # update points
    PointManager::add_points model.user, 'cs' if model.user
  end
end
