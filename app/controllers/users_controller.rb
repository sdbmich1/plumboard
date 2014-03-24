class UsersController < ApplicationController
  before_filter :check_permissions, only: [:index]
  before_filter :authenticate_user!
  before_filter :load_target, only: [:update]
  respond_to :html, :js, :json, :mobile

  def index
    @users = User.all
  end

  def show
    @user = User.find params[:id]
    @photo = @user.pictures
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    changing_email = params[:user][:email] != @user.email
    if @user.update_attributes(params[:user])
      flash.now[:notice] = flash_msg changing_email
      @user = User.find params[:id]
    else
      respond_with(@user)
    end
  end

  def states
    respond_with(@states = State.all)
  end

  def buyer_name
    @users = User.search query, star: true, :page => params[:page], :per_page => 10
    respond_with(@users)
  end

  private

  def load_target
    @target = params[:target]
  end

  # loads confirmation message
  def flash_msg chg_email
    if chg_email 
      (@user.pending_reconfirmation?) ?
        t("devise.registrations.update_needs_confirmation") : t("devise.registrations.updated")
    else 
      'Saved changes successfully.'
    end
  end

  def query
    @query = Riddle::Query.escape params[:search]
  end 

  def check_permissions
    authorize! :manage, @users
  end
end
