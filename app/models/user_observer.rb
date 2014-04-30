class UserObserver < ActiveRecord::Observer
  observe User

  # set default user type
  def before_create usr
    usr.user_type_code = 'mbr'
  end

  # update points
  def after_update usr
    ptype = usr.changes[:last_sign_in_at] ? 'lb' : 'act'
    PointManager::add_points usr, ptype
  end
end
