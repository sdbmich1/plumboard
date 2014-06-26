class CardAccountsController < ApplicationController
  before_filter :authenticate_user!
  # before_filter :check_permissions
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def new
    @account = @user.card_accounts.build
  end

  def index
    @accounts = @user.card_accounts
    respond_with(@accounts) do |format|
      format.json { render json: {accounts: @accounts} }
    end
  end

  def show
    @account = @user.card_accounts.first
    respond_with(@account) do |format|
      format.json { render json: {account: @account} }
    end
  end

  def create
    @account = CardAccount.new params[:card_account]
    respond_with(@account) do |format|
      if @account.save_account
        flash.now[:notice] = 'Successfully created account.'
        format.json { render json: @account }
      else
        flash.now[:error] = 'Error occurred creating account. Please try again.'
	format.json { render :json => { :errors => @account.errors.full_messages }, :status => 422 }
      end
    end
  end

  def destroy
    @account = CardAccount.find params[:id]
    if @account.delete_card
      flash.now[:notice] = 'Successfully removed account.'
      redirect_to get_root_path 
    else
      flash.now[:error] = @account.errors
      render nothing: true 
    end
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def check_permissions
    authorize! :crud, CardAccount
  end
end
