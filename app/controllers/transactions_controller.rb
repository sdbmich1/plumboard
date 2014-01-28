class TransactionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_vars, :except => [:index, :refund]
  respond_to :html, :js, :json, :mobile
  include CalcTotal
  layout :page_layout

  def new
    @listing = Listing.find_by_pixi_id(params[:id]) || TempListing.find_by_pixi_id(params[:id])
    @transaction = Transaction.load_new(@user, @listing, @order)
    @invoice = Invoice.find_invoice(@order) unless @transaction.pixi?
    respond_with(@transaction)
  end

  def create
    @listing = Listing.find_by_pixi_id(params[:id]) || TempListing.find_by_pixi_id(params[:id])
    @transaction = @user.transactions.build params[:transaction] 
    respond_with(@transaction) do |format|
      if @transaction.save_transaction(params[:order], @listing)
        format.json { render json: {transaction: @transaction} }
      else
        format.html { redirect_to new_transaction_path(order: @order, id: params[:id]), error: @transaction.errors.full_messages }
        format.json { render json: { errors: @transaction.errors.full_messages }, status: 422 }
      end
    end
  end

  def show
    @transaction = Transaction.find params[:id]
    @rating = @user.ratings.build
    respond_with(@transaction) do |format|
      format.json { render json: {transaction: @transaction} }
    end
  end

  def index
    @transactions = Transaction.all
    respond_with(@transactions) do |format|
      format.json { render json: {transactions: @transactions} }
    end
  end

  protected

  def page_layout
    mobile_device? ? 'form' : 'transactions'
  end

  def load_vars    
    @order = action_name == 'new' ? params : params[:order] ? params[:order] : params
    @qtyCnt = action_name == 'new' ? @order[:qtyCnt].to_i : 0
    @discount = CalcTotal::get_discount
  end
end
