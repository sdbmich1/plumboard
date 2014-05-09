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

    # set role if user type changes
    if usr.user_type_code_changed?
      case usr.user_type_code
        when 'PX'; role = 'editor'
        when 'PT'; role = 'pixter'
        when 'AD'; role = 'admin'
	else
	  role = 'member'
      end

      # set role
      unless role == 'member'
        usr.add_role(role.to_sym) if usr.roles.find_by_name(role.to_s.camelize).blank? rescue nil
      end
    end
  end
end
