class ApplicationController < ActionController::Base
  include UrlHelper
  protect_from_forgery with: :null_session, if: Proc.new {|c| c.request.format.json? }
  before_filter :load_settings
  before_filter :prepare_for_mobile, if: :isDev?, except: [:destroy]
  # skip_before_filter :prepare_for_mobile
  after_filter :set_access_control_headers
  helper_method :mobile_device?

  # Handle authorization exceptions
  rescue_from CanCan::AccessDenied do |exception|
    if request.xhr?
      render_json_error exception
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

  def render_json_error exception
    if signed_in?
      render json: {status: :error, message: "You have no permission to #{exception.action} #{exception.subject.class.to_s.pluralize}"}, status: 403
    else
      render json: {:status => :error, :message => "You must be logged in to do that!"}, :status => 401
    end
  end

  def isDev?
    false # Rails.env.development?
  end

  def check_mobile_session
    if session[:mobile_param]  
      session[:mobile_param] == "1"  
    else  
      request.user_agent =~ /iPhone;|Android|BlackBerry|Symbian|Windows Phone/  
    end  
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
    if @user.is_business?
      !@user.has_bank_account? ? new_bank_account_path(uid: @user) : !@user.has_prefs? ? settings_delivery_path : get_root_path
    else
      session[:back_to] || session[:return_to] || get_root_path
    end
  end

  # set user if signed in 
  def load_settings
    @user = signed_in? ? current_user : User.new
    # @region = session[:home_id] || LocationManager::retrieve_loc(action_name, request)
    # session[:home_id] ||= @region
    session[:home_id] ||= AppFacade.new(params).set_region action_name, request, session[:home_id]
  end

  # set store path
  def store_location
    session[:return_to] = request.fullpath
    session[:back_to] = nil
  end

  # clear stored path
  def clear_stored_location
    session[:return_to] = nil
  end

  # exception handling
  def rescue_with_handler(exception)
    if Rails.env.production? || Rails.env.staging? || Rails.env.demo?
      ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver 
      redirect_to '/500.html'
    end
  end       

  def action_missing(id, *args)
    if Rails.env.production? || Rails.env.staging? || Rails.env.demo?
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
    ControllerManager::set_root_path @cat, session[:home_id]
  end

  # check if mobile device based on user_agent 
  def mobile_device?
    isDev? ? check_mobile_session : false
  end

  # attempt to render mobile version of page first
  def check_for_mobile
    prepend_view_path "app/views/mobile" if mobile_device?
  end

  def set_session
    session[:back_to] = request.path unless signed_in?
  end

  def render_csv klass, items, format, status=nil
    format.csv { send_data(render_to_string(csv: items, style: status), disposition: 
      "attachment; filename=#{klass.constantize.filename status}.csv") }
  end

  def render_items klass, model, items, method='status'
    result = model.send(method) rescue klass
    respond_with(model) { |format| render_csv klass, items, format, result }
  end
end
