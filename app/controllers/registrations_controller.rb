class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  respond_to :html, :json, :mobile, :js

  protected 

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  def configure_permitted_parameters
    params = [:first_name, :last_name, :user_type_code, :business_name,
              :ein, :ssn_last4, :url, :birth_date, :gender, :description,
              preferences_attributes: [:zip],
              pictures_attributes: [:direct_upload_url, :photo_file_name,
                :photo_file_path, :photo_file_size, :photo_content_type,
                :commit]]
    devise_parameter_sanitizer.for(:sign_up).push(params)
  end

  private

  def page_layout
    action_name == 'new' ? 'pages' : 'application'
  end
end
