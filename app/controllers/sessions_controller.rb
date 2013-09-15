class SessionsController < Devise::SessionsController
  layout :page_layout

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    redirect_to root_url
  end

  def failure
    redirect_to root_url, :flash => {:error => "Could not log you in. #{params[:message]}"}
  end

  protected

  def page_layout
    action_name == 'new' ? 'pages' : 'application'
  end

end
