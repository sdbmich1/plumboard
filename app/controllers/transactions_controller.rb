class TransactionsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_vars, :except => [:index, :refund]
  before_filter :load_pixi, only: [:new, :create]
  respond_to :html, :js, :json, :mobile
  include CalcTotal
  layout :page_layout

  def new
    respond_with(@transaction = Transaction.load_new(@user, @listing, @order))
  end

  def create
    @transaction = Transaction.new params[:transaction] 
    respond_with(@transaction) do |format|
      if @transaction.save_transaction(params[:order], @listing)
        format.json { render json: {transaction: @transaction} }
      else
        format.json { render json: { errors: @transaction.errors.full_messages }, status: 422 }
      end
    end
  end

  def show
    respond_with(@transaction = Transaction.find(params[:id]))
  end

  def index
    respond_with(@transactions = Transaction.all)
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

  def load_pixi
    @listing = Listing.find_by_pixi_id(params[:id]) || TempListing.find_by_pixi_id(params[:id])
    @invoice = Invoice.find_invoice(@order)
  end
end
