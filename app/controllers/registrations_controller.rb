class RegistrationsController < Devise::RegistrationsController
  include ControllerManager
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :set_params, only: [:create]
  respond_to :html, :json, :mobile, :js
  # layout :page_layout

  def create
    if params[:file].blank?
      super
    else
      # process json for mobile
      user = User.new(params[:user])
      pic = user.pictures.build
      pic.photo = File.new params[:file].tempfile 

      warden.custom_failure! unless user.save
      respond_with(user) do |format|
        format.json { render json: {user: [email: user.email, auth_token: user.authentication_token]}, status: :ok }
      end
    end
  end

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

  def set_params
    params[:user] = JSON.parse(params[:user]) unless params[:file].blank?
  end
end
