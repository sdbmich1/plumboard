module SettingsHelper

  # add new details for user
  def setup_user(user)
    user.contacts.blank? ? user.contacts.build : user.contacts
    return user
  end
end
