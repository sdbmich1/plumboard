class PostObserver < ActiveRecord::Observer
  observe Post
  include PointManager

  def after_create model
    # send notice to recipient
    UserMailer.send_notice(model).deliver_later unless model.system_msg? || model.want_msg? || model.ask_msg? || model.inv_msg?

    # update points
    PointManager::add_points model.user, 'cs' if model.user
  end
end
