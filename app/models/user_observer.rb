class UserObserver < ActiveRecord::Observer
  observe User
  include PointManager

  # update points
  def after_create usr
    ptype = usr.uid.blank? ? 'dr' : 'fr'
    PointManager::add_points usr, ptype
  end

  # update points
  def after_update usr
    ptype = usr.changes[:last_sign_in_at] ? 'lb' : 'act'
    PointManager::add_points usr, ptype
  end
end
