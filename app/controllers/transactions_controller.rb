require 'calc_total'
class TransactionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_vars, :except => [:index, :refund]
  respond_to :html, :js, :json
  include CalcTotal

  def new
    @listing = TempListing.find_by_pixi_id params[:id]
    @transaction = Transaction.load_new(@user, @listing, @order)
  end

  def create
    @listing = TempListing.find_by_pixi_id params[:id]
    @transaction = Transaction.new(params[:transaction])
    @transaction.save_transaction(params[:order], @listing)
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
#    @total = @fees = 0 
    @order = action_name == 'new' ? params : params[:order] ? params[:order] : params
    @qtyCnt = action_name == 'new' ? @order[:qtyCnt].to_i : 0
    @discount = CalcTotal::get_discount
  end
end
