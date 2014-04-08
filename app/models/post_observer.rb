class PostObserver < ActiveRecord::Observer
  observe Post
  include PointManager

  def after_create model
    # send notice to recipient
    UserMailer.delay.send_notice(model) unless pixi_sys_msg?(model)

    # update points
    PointManager::add_points model.user, 'cs' if model.user
  end

  # check if system msg for pixi
  def pixi_sys_msg? model
    %w(approve deny).detect{ |x| model.msg_type == x }
  end
end
