class PromoCodeUsersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json, :mobile

  def create
    respond_with(@promo = PromoCodeUser.save(params[:uid], params[:id], 'active'))
  end

  def index
    @promo = PromoCodeUser.get_by_user(params[:uid], params[:status]).paginate(page: params[:page], per_page: params[:per_page])
    respond_with(@promo) do |format|
      format.json { render json: {promo: @promo} }
    end
  end

  def update
    @promo = PromoCodeUser.save(params[:uid], params[:id], 'removed')
    respond_with(@promo, location: "nil")
  end

end
