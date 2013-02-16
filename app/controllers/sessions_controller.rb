class SessionsController < Devise::SessionsController

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    redirect_to root_url
  end

  def failure
    redirect_to root_url, :flash => {:error => "Could not log you in. #{params[:message]}"}
  end

end
