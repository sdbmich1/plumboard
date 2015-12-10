class UserObserver < ActiveRecord::Observer
  observe User
  include NameParse, Payment

  def before_update usr
    if usr.description_changed?
      NameParse::encode_string usr.description
    end
  end

  # update points
  def after_update usr
    ptype = usr.changes[:last_sign_in_at] ? 'lb' : 'act'
    PointManager::add_points usr, ptype

    # set role if user type changes
    if usr.birth_date_changed? && usr.has_bank_account?
      StripePayment.update_account usr, usr.acct_token, usr.current_sign_in_ip
    end

    # set role if user type changes
    if usr.user_type_code_changed?
      case usr.user_type_code
        when 'PX', 'ED'; role = 'editor'
        when 'PT'; role = 'pixter'
        when 'AD'; role = 'admin'
        when 'SP'; role = 'support'
	else
	  role = 'member'
      end

      # set role
      unless role == 'member'
        usr.add_role(role.to_sym) unless usr.has_role? role.to_sym
      end
    end
  end
end
