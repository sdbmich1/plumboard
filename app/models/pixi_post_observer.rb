class PixiPostObserver < ActiveRecord::Observer
  observe PixiPost
  include PointManager

  # send receipt upon request
  def after_create post
      
    # update points
    PointManager::add_points post.user, 'ppx' 
      
    UserMailer.delay.send_pixipost_request(post) if post.status == 'active'
    UserMailer.delay.send_pixipost_appt(post) if post.has_appt? && !post.is_completed?
  end
end
