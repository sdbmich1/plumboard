class SessionsController < Devise::SessionsController
  include ControllerManager
  before_filter :set_flg, only: [:new]
  after_filter :transfer_guest_acct, only: [:create]
  layout :page_layout
  respond_to :html, :js, :json, :mobile

  def create
    resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#new")
    sign_in(resource_name, resource)

    respond_to do |format|
      format.html { super }
      format.mobile { super }
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

  def set_flg
    @xhr = true if request.xhr?
  end

  private

  def transfer_guest_acct
    ControllerManager::transfer_guest_acct session, resource
  end
end
