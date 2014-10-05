class SessionsController < Devise::SessionsController
  layout :page_layout
  respond_to :html, :js, :json, :mobile

  def create
    resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
    sign_in(resource_name, resource)

    respond_to do |format|
      format.html do
        super
      end
      format.mobile do
        super
      end
      format.json do
	render json: { response: 'ok', auth_token: current_user.authentication_token }.to_json, status: :ok
      end
    end
  end

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    redirect_to root_url
  end

  def failure
    redirect_to root_url, :flash => {:error => "Could not log you in. #{params[:message]}"}
  end

  protected

  def page_layout
    'application'
  end

end
