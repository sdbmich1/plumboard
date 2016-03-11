class PixiPostObserver < ActiveRecord::Observer
  observe PixiPost
  include PointManager, AddressManager

  # send receipt upon request
  def after_create post
      
    # update points
    PointManager::add_points post.user, 'ppx' 

    # update buyer address info
    update_contact_info post
      
    UserMailer.send_pixipost_request(post).deliver_later if post.status == 'active'
    UserMailer.send_pixipost_request_internal(post).deliver_later if post.status == 'active'
  end

  # send appointment notice
  def after_update post
    UserMailer.send_pixipost_appt(post).deliver_later if post.has_appt? && !post.is_completed?
  end

  # update user contact info if no address is already saved
  def update_contact_info post
    AddressManager::set_user_address post.user, post
  end
end
