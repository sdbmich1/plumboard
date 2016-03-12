class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json, :mobile, :js

  protected 

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  private

  def page_layout
    action_name == 'new' ? 'pages' : 'application'
  end
end
