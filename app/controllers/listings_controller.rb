class ListingsController < ApplicationController
  require 'will_paginate/array' 
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :seller]
  respond_to :html, :json, :js
  layout :page_layout

  def index
    @listings = Listing.active_page @page
  end

  def show
    @listing = Listing.find_by_pixi_id params[:id]
    @post = Post.new 
    @photo = @listing.pictures
  end

  def destroy
    @listing = Listing.find_by_pixi_id params[:id]
    flash[:notice] = 'Successfully removed pixi.' if @listing.destroy 
    respond_with @listing
  end

  def seller
    @listings = @user.pixis.paginate(:page => @page)
  end

  protected

  def page_layout
    action_name == 'index' ? 'listings' : 'application'
  end

  def load_data
    @page = params[:page] || 1
  end
end
