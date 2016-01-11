class BankAccountsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_vars, :set_user
  before_filter :load_target, only: [:new, :create, :edit, :update]
  before_filter :load_data, only: [:show, :destroy]
  before_filter :load_accts, only: [:index]
  after_filter :mark_message, only: [:new]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :json, :js, :mobile
  layout :page_layout
  include ControllerManager

  def new
    flash.now[:notice] = 'You need to setup a bank account in order to receive payments.' unless @usr.has_bank_account?
    respond_with(@account = BankAccount.new(user_id: params[:uid]))
  end

  def index
    respond_with(@accounts)
  end

  def show
    respond_with(@account)
  end

  def create
    @account = BankAccount.new params[:bank_account]
    respond_with(@account) do |format|
      if @account.save_account request.remote_ip
        load_accts if @adminFlg
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
    if @account.delete_account 
      set_return_path
    else
      flash[:error] = @account.errors.full_messages
      render action: :show 
    end
  end

  protected

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
      @account = @usr.reload.bank_accounts.first if @usr
    end
  end

  # redirect based on target
  def redirect_path
    !(@target =~ /invoice/i).nil? ? redirect_to(new_invoice_path) : set_reload_path
  end

  def set_reload_path
    @adminFlg ? redirect_to(bank_accounts_path(adminFlg: @adminFlg)) : set_settings_path
  end

  def set_settings_path
    @usr.is_business? && !@usr.has_prefs? ? redirect_to(settings_delivery_path) : redirect_to(@account)
  end

  def set_return_path
    @adminFlg ? load_accts : redirect_to(new_bank_account_path)
  end

  def mark_message
    ControllerManager::mark_message params[:cid], @usr if params[:cid]
  end

  def set_user
    @usr = params[:uid].blank? ? @user : User.find(params[:uid])
  end

  def load_vars
    @adminFlg = params[:adminFlg].to_bool rescue false
  end

  def load_accts
    @accounts = BankAccount.acct_list(@usr, @adminFlg).paginate(page: params[:page], per_page: 15)
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    super(parameters).active rescue nil
  end
end
