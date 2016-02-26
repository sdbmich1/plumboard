class CardAccountsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_vars, :set_user
  before_filter :load_data, only: [:show, :destroy]
  before_filter :load_accts, only: [:index]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def new
    respond_with(@account = CardAccount.new(user_id: params[:uid]))
  end

  def index
    respond_with(@accounts)
  end

  def show
    respond_with(@account)
  end

  def create
    @account = CardAccount.new params[:card_account]
    respond_with(@account) do |format|
      if @account.save_account
        load_accts if @adminFlg
        format.json { render json: @accounts }
      else
	format.json { render :json => { :errors => @account.errors.full_messages }, :status => 422 }
      end
    end
  end

  def destroy
    respond_with(@account) do |format|
      if @account.delete_card 
        load_accts
        format.json { render json: @accounts }
      else
        flash[:error] = @account.errors.full_messages
        format.html { render :show }
        format.json { render :json => { :errors => @account.errors.full_messages }, :status => 422 }
      end
    end
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'transactions'
  end

  def load_data
    @account = CardAccount.find params[:id]
  end

  def load_accts
    @accounts = CardAccount.card_list(@usr, @adminFlg).paginate(page: params[:page], per_page: 15)
  end

  def set_user
    @usr = params[:uid].blank? ? @user : User.find(params[:uid])
  end

  def load_vars
    @adminFlg = params[:adminFlg].to_bool rescue false
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    super(parameters).active rescue nil
  end
end
