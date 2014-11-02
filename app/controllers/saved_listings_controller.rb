require 'will_paginate/array' 
class SavedListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  after_filter -> { reload_data params[:id] }, only: [:create, :destroy]
  respond_to :html, :js, :mobile, :json

  def index
    @listings = Listing.saved_list @user, @page
    respond_with(@listings) do |format|
      format.json { render json: {listings: @listings} }
    end
  end

  def create
    @listing = @user.saved_listings.build pixi_id: params[:id]
    respond_with(@listing) do |format|
      if @listing.save
        format.json { render json: {saved_listing: @listing} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @listing = @user.saved_listings.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.destroy
        format.json { render json: {head: :ok} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  private

  def reload_data pid
    @listing = Listing.find_by_pixi_id pid
  end

  def load_data
    @page = params[:page] || 1
  end
end
