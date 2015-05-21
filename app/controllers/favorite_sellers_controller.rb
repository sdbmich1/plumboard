require 'will_paginate/array'
class FavoriteSellersController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def create
    @favorite = @user.favorite_sellers.find_or_create_by_seller_id(params[:seller_id])
    @favorite.update_attribute(:status, 'active')
    respond_with(@favorite)
  end

  def index
  end

  def update
    @favorite = @user.favorite_sellers.find_by_seller_id(params[:seller_id])
    @favorite.update_attribute(:status, 'removed')
    respond_with(@favorite)
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end
end
