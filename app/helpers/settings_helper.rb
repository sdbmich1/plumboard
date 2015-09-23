module SettingsHelper

  # add new details for user
  def setup_user(user, contactFlg=true)
    if contactFlg
      user.contacts.blank? ? user.contacts.build : user.contacts
    else
      user.preferences.blank? ? user.preferences.build : user.preferences
    end
    return user
  end

  # check if item is editable based on action
  def edit_account? 
    (controller_name == 'settings' && action_name == 'index') || (controller_name == 'users' && action_name == 'edit')
  end

  def show_pwd_link
    content_tag(:li, link_to("Password", settings_password_path, class: 'submenu', remote: true, id: 'pwd-setting')) unless @user.fb_user?
  end
end
