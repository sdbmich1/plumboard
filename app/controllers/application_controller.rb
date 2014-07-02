class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_settings
  before_filter :prepare_for_mobile, if: :isDev?, except: [:destroy]
  # skip_before_filter :prepare_for_mobile
  after_filter :set_access_control_headers
  helper_method :mobile_device?

  # check if mobile device based on user_agent 
  def mobile_device?
    if isDev?
      if session[:mobile_param]  
        session[:mobile_param] == "1"  
      else  
        request.user_agent =~ /iPhone;|Android|BlackBerry|Symbian|Windows Phone/  
      end  
    else
      false
    end  
  end

  # attempt to render mobile version of page first
  def check_for_mobile
    prepend_view_path "app/views/mobile" if mobile_device?
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
      redirect_to root_url, alert: exception.message
    end
  end

  # handle forbidden routes
  rescue_from ActionController::RoutingError, :with => :render_forbidden_error

  protected

  def authenticate_user!
    request.xhr? ? clear_stored_location : store_location
    super
  end

  def isDev?
    false # Rails.env.development?
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers["Access-Control-Allow-Headers"] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(",")
    head(:ok) if request.request_method == "OPTIONS"
  end

  def after_sign_in_path_for(resource)
    @user ||= resource
    session[:return_to] || get_root_path # categories_path(newFlg: @user.new_user?)
  end

  # set user if signed in 
  def load_settings
    @user = signed_in? ? current_user : User.new
    @region ||= LocationManager::get_loc_id(PIXI_LOCALE)
  end

  # set store path
  def store_location
    session[:return_to] = request.fullpath
  end

  # clear stored path
  def clear_stored_location
    session[:return_to] = nil
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

  def render_forbidden_error
    respond_to do |format|
      format.html { redirect_to get_root_path, alert: "You cannot access that part of the website." }
      format.mobile { redirect_to get_root_path, alert: "You cannot access that part of the website." }
      format.xml { head :forbidden }
      format.json { head :forbidden }
    end
  end

  # used for mobile web site
  def prepare_for_mobile  
    session[:mobile_param] = params[:mobile] if params[:mobile]  
    # request.format = :mobile if mobile_device? && !request.xhr?

    if mobile_device? and request.format.to_s == "text/html"
      request.format = :mobile
    elsif request.format.to_s == "text/javascript"
      request.format = :js
    end
  end 

  # disable json requests for mobile
  def protect_against_forgery?
    super unless request.format == :json
  end

  # used to block CSRF attacks
  def handle_unverified_request
    super
    Devise.mappings.each_key do |key|
      cookies.delete "remember_#{key}_token"
    end
  end

  # set current ability
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  # set root path based on pixi count
  def get_root_path
    Listing.has_enough_pixis?(@cat, @region, @page) ? categories_path(loc: @region) : local_listings_path(loc: @region)
  end
end
