class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_settings

  protected

  def authenticate_user!
    session[:return_to] = request.fullpath
    super
  end

  def after_sign_in_path_for(resource)
    @user ||= resource
    @user.sign_in_count <= 1 ? welcome_path(@user) : session[:return_to] || listings_path
  end

  def load_settings
    if signed_in?
      @user = current_user
    else
      @user = User.new
    end
  end
end
