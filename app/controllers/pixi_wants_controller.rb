class PixiWantsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data
  respond_to :html, :js, :mobile, :json

  def create
    @want = PixiWant.save(user_id: @user.id, pixi_id: params[:id], status: 'active', quantity: params[:qty] || 1)
    respond_with(@want) do |format|
      reload_data params[:id]
      format.json { render json: { pixi_want: @want } }
    end
  end

  def buy_now
    @want = PixiWant.save(user_id: @user.id, pixi_id: params[:id], status: 'active', quantity: params[:qty])
    respond_with(@want) do |format|
      process_invoice params[:id]
      format.html { redirect_to new_transaction_path(@order) and return }
      format.json { render json: { pixi_want: @want, order: @order.to_json } }
    end
  end

  protected

  def load_data
    @url = params[:url]
  end

  def reload_data pid
    @listing = Listing.find_by_pixi_id pid
  end

  def process_invoice pid
    reload_data(pid)
    @order = Invoice.process_invoice(@listing, @user.id, params[:fulfillment_type_code])
  end
end
