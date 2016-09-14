require 'will_paginate/array'
class FavoriteSellersController < ApplicationController
  # load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_data, only: :index
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def create
    @favorite = FavoriteSeller.save(params[:uid], params[:seller_id], 'active')
    respond_with(@favorite)
  end

  def index
    respond_with(@users = User.get_by_ftype(@ftype, @id, @status).paginate(page: @page, per_page: 15))
  end

  def update
    @favorite = FavoriteSeller.save(params[:uid], params[:seller_id], 'removed')
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
