class UserObserver < ActiveRecord::Observer
  observe User
  include PointManager

  def after_create usr
    # update points
    ptype = usr.uid.blank? ? 'dr' : 'fr'
    PointManager::add_points usr, ptype

    # send welcome message to facebook users
    UserMailer.delay.welcome_email(usr) if usr.fb_user?
  end

  # update points
  def after_update usr
    ptype = usr.changes[:last_sign_in_at] ? 'lb' : 'act'
    PointManager::add_points usr, ptype
  end
end
