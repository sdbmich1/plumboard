class PostObserver < ActiveRecord::Observer
  observe Post
  include PointManager

  # update points
  def after_create model
    PointManager::add_points model.user, 'cs' if model.user
  end
end
