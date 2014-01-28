class RatingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :mobile, :json

  def create
    @rating = @user.ratings.build params[:rating]
    @transaction = Transaction.find params[:id]
    respond_with(@rating) do |format|
      if @rating.save
        format.html { redirect_to root_path }
        format.mobile { redirect_to root_path }
        format.json { render json: {rating: @rating} }
      else
        format.html { redirect_to transaction_path(@transaction) }
        format.mobile { redirect_to transaction_path(@transaction) }
        format.json { render json: { errors: @rating.errors.full_messages }, status: 422 }
      end
    end
  end
end
