class BankAccountsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_target, only: [:new, :create, :edit, :update]
  before_filter :load_data, only: [:show, :destroy]
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def new
    flash.now[:notice] = 'You need to setup a bank account before creating an invoice.' unless @user.has_bank_account?
    @account = @user.bank_accounts.build
  end

  def index
    respond_with(@accounts = @user.bank_accounts.active)
  end

  def show
    respond_with(@account)
  end

  def create
    @account = BankAccount.new params[:bank_account]
    respond_with(@account) do |format|
      if @account.save_account request.remote_ip
        format.js { reload_data }
	format.html { redirect_path }
        format.json { render json: {account: @account} }
      else
	format.html { render :new }
	format.json { render :json => { :errors => @account.errors.full_messages }, :status => 422 }
      end
    end
  end

  def destroy
    @account.delete_account if @account
    respond_with(@account, location: get_root_path)
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'transactions'
  end

  def load_data
    @account = BankAccount.find params[:id]
  end

  # load target partial form
  def load_target
    @target = params[:target]
  end
  
  # reload data based on target 
  def reload_data
    if !(@target =~ /invoice/i).nil?
      @invoice = @user.invoices.build
    else
      @account = @user.reload.bank_accounts.first if @user
    end
  end

  # redirect based on target
  def redirect_path
    if !(@target =~ /invoice/i).nil?
      redirect_to new_invoice_path
    else
      redirect_to @account
    end
  end
end
