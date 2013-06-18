class BankAccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_target, only: [:new, :create, :edit, :update]
  respond_to :html, :json, :js

  def new
    @account = @user.bank_accounts.build
  end

  def index
    @accounts = @user.bank_accounts
  end

  def edit
    @account = BankAccount.find params[:id]
  end

  def update
    @account = BankAccount.find params[:id]
    flash.now[:notice] = 'Successfully updated account.' if @account.update_attributes(params[:bank_account])
  end

  def create
    @account = BankAccount.new params[:bank_account]
    if @account.save 
      flash.now[:notice] = 'Successfully created account.' 
      respond_to do |format|
        format.js { reload_data }
        format.html { redirect_path }
      end
    else
      flash.now[:error] = @account.errors
      render :nothing => true
    end
  end

  def destroy
    @account = BankAccount.find params[:id]
    if @account.destroy 
      flash.now[:notice] = 'Successfully removed account.' 
      @accounts = User.find(@user).bank_accounts rescue nil
    end
  end

  private

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
      redirect_to settings_path
    end
  end
end
