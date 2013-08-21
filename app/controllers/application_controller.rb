class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_settings

  protected

  def authenticate_user!
    request.xhr? ? clear_stored_location : store_location
    super
  end

  def after_sign_in_path_for(resource)
    @user ||= resource
    session[:return_to] || listings_path
  end

  # set user if signed in 
  def load_settings
    @user = signed_in? ? current_user : User.new
  end

  # set store path
  def store_location
    session[:return_to] = request.fullpath
  end

  # clear stored path
  def clear_stored_location
    session[:return_to] = nil
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
      flash[:error] = exception.message
      redirect_to root_url
    end
  end

  # exception handling
  def rescue_with_handler(exception)
    if Rails.env.production? || Rails.env.staging?
      ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver 
      redirect_to '/500.html'
    end
  end       

  def action_missing(id, *args)
    if Rails.env.production? || Rails.env.staging?
      redirect_to '/404.html'
    end
  end
end
