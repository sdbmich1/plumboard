require 'will_paginate/array'
class FavoriteSellersController < ApplicationController
  # load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_data, only: :index
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def create
    @favorite = FavoriteSeller.find_or_create_by(user_id: params[:uid], seller_id: params[:seller_id], status: 'removed')
    @favorite.update_attribute(:status, 'active')
    respond_with(@favorite)
  end

  def index
    respond_with(@users = User.get_by_ftype(@ftype, @id, @status).paginate(page: @page, per_page: 15))
  end

  def update
    @favorite = FavoriteSeller.find_or_create_by(user_id: params[:uid], seller_id: params[:seller_id], status: 'active')
    @favorite.update_attribute(:status, 'removed')
    respond_with(@favorite)
  end

  private

  def load_data
    @ftype, @id, @status, @page = params[:ftype], params[:id], params[:status], params[:page]
  end

  def page_layout
    mobile_device? ? 'form' : 'application'
  end
end
