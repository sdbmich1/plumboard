class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token, :only => :create
  layout :page_layout

  def create
    user = User.new(params[:user])
    if user.save
      render :json=> {:user => [:email => user.email, :auth_token => user.authentication_token]}, :status => 201
      return
    else
      warden.custom_failure!
      render :json=> user.errors, :status=>422
    end
  end

  def after_sign_up_path_for(resource)
    listings_path
  end
	      
  def page_layout
    action_name == 'new' ? 'pages' : 'application'
  end
end
