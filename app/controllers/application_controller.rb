class ApplicationController < ActionController::Base
  # protect_from_forgery
  before_filter :load_settings

  protected

  def authenticate_user!
    session[:return_to] = request.fullpath
    super
  end

  def after_sign_in_path_for(resource)
    @user ||= resource
    @user.sign_in_count <= 1 ? welcome_path(@user) : listings_path
  end

  # set user if signed in 
  def load_settings
    @user = signed_in? ? current_user : User.new
  end

  # Handle authorization exceptions
  rescue_from CanCan::AccessDenied do |exception|
    if request.xhr?
      if signed_in?
	render json: {status: :error, message: "You have no permission to #{exception.action} #{exception.subject.class.to_s.pluralize}"}, status: 403
      else
        render json: {:status => :error, :message => "You must be logged in to do that!"}, :status => 401
      end
    else
      redirect_to root_url, :alert => exception.message
    end
  end
end
