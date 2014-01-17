class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :set_params, only: [:create]
  respond_to :html, :json, :mobile, :js
  # layout :page_layout

  def create
    user = User.new(params[:user])

    if params[:file]
      pic = user.pictures.build
      pic.photo = File.new params[:file].tempfile 
    end

    warden.custom_failure! unless user.save

    respond_with(user) do |format|
      format.json { render json: {user: [email: user.email, auth_token: user.authentication_token]}, status: :ok }
    end
  end

  def after_sign_up_path_for(resource)
    listings_path
  end

  private
	      
  def page_layout
    action_name == 'new' ? 'pages' : 'application'
  end

  def set_params
    respond_to do |format|
      format.html
      format.json { params[:user] = JSON.parse(params[:user]) }
    end
  end
end
