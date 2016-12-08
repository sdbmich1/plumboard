class PromoCodeUsersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json, :mobile

  def create
    respond_with(@promo = PromoCodeUser.save(params[:id], params[:uid], 'active'))
  end

  def index
    respond_with(@promo = PromoCodeUser.get_by_user(params[:uid], params[:status]).paginate(params[:page], params[:per_page]))
  end

  def update
    @promo = PromoCodeUser.save(params[:id], params[:uid], 'removed')
    respond_with(@promo, location: "nil")
  end

end
