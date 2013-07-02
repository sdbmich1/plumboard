class CommentObserver < ActiveRecord::Observer
  observe Comment
  include PointManager

  # update points
  def after_create model
    PointManager::add_points model.user, 'pc' if model.user
  end
end
