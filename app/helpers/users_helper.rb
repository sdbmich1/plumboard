module UsersHelper

  # toggle boolean to string
  def toggle_bool val
    val ? 'Yes' : 'No'
  end

  # toggle menu status
  def toggle_active val, utype
    val == utype ? 'active' : ''
  end
  
  # display options based on access
  def check_access usr
    access?(usr) ? UserType.active : UserType.unhidden
  end

  # toggle visible
  def is_visible? usr, flg
    flg && usr.is_business? ? 'display:none' : ''
  end

  # check usr access
  def access? usr
    can?(:manage_users, usr)
  end
end
