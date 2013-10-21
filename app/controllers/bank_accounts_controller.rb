class BankAccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_target, only: [:new, :create, :edit, :update]
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def new
    @account = @user.bank_accounts.build
  end

  def index
    @accounts = @user.bank_accounts
  end

  def create
    @account = BankAccount.new params[:bank_account]
    if @account.save_account 
      flash.now[:notice] = 'Successfully created account.' 
      respond_to do |format|
        format.js { reload_data }
        format.html { redirect_path }
      end
    end
  end

  def destroy
    @account = BankAccount.find params[:id]
    if @account.delete_account 
      flash.now[:notice] = 'Successfully removed account.' 
      redirect_to listings_path
    else
      flash.now[:error] = @account.errors
      render :nothing => true
    end
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'application'
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
      @account = User.find(@user).bank_accounts.first
    end
  end

  # redirect based on target
  def redirect_path
    if !(@target =~ /invoice/i).nil?
      redirect_to new_invoice_path
    else
      redirect_to listings_path
    end
  end
end
