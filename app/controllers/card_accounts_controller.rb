class CardAccountsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_data, only: [:show, :destroy]
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def new
    respond_with(@account = @user.card_accounts.build)
  end

  def index
    respond_with(@accounts = @user.card_accounts)
  end

  def show
    respond_with(@account)
  end

  def create
    @account = CardAccount.new params[:card_account]
    respond_with(@account) do |format|
      if @account.save_account
        format.json { render json: @account }
      else
	format.json { render :json => { :errors => @account.errors.full_messages }, :status => 422 }
      end
    end
  end

  def destroy
    if @account.delete_card 
      redirect_to new_card_account_path 
    else
      flash[:error] = @account.errors.full_messages
      render :show 
    end
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'transactions'
  end

  def load_data
    @account = CardAccount.find params[:id]
  end
end
