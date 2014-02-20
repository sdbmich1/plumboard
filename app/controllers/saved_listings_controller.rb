require 'will_paginate/array' 
class SavedListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  respond_to :html, :js, :mobile, :json

  def index
    @listings = Listing.saved_list @user, @page
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def create
    @listing = @user.saved_listings.build pixi_id: params[:pixi_id]
    respond_with(@listing) do |format|
      if @listing.save
        reload_data params[:pixi_id]
        format.json { render json: {saved_listing: @listing} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @listing = @user.saved_listings.find_by_pixi_id params[:pixi_id]
    respond_with(@listing) do |format|
      if @listing.destroy
	reload_data params[:pixi_id]
        format.json { render json: {head: :ok} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  private

  def reload_data pid
    @listing = Listing.find_by_pixi_id pid
    @like = @user.pixi_likes.find_by_pixi_id pid rescue nil
    @saved = @user.saved_listings.find_by_pixi_id pid rescue nil
    @contact = @user.posts.find_by_pixi_id pid rescue nil
  end

  def load_data
    @page = params[:page] || 1
  end
end
