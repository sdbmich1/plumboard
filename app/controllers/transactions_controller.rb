class TransactionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_vars, :except => [:index, :refund]
  respond_to :html, :js, :json

  def new
    @user = User.find params[:user_id]
    @transaction = Transaction.load_new(@user)
  end

  def build
    @listing = TempListing.find params[:id]
    @user = User.find params[:user_id]
    @transaction = Transaction.load_new(@user)
    respond_with(@transaction)
  end

  def create
    @listing = TempListing.find params[:id]
    @transaction = Transaction.new(params[:transaction])
    @transaction.save_transaction(params[:order])
    respond_with(@transaction)
  end

  def show
    @transaction = Transaction.find params[:id]
  end

  def index
    @transactions = Transaction.all
  end

  protected

  def load_vars    
    @total = @fees = 0 
    @order = action_name == 'build' ? params : params[:order] ? params[:order] : params
    @qtyCnt = action_name == 'new' ? @order[:qtyCnt].to_i : 0
    @discount = PromoCode.get_code(@order[:promo_code], Date.today)   
  end


end
