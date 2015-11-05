require 'will_paginate/array' 
class SavedListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  respond_to :html, :js, :mobile, :json

  def index
    respond_with(@listings = Listing.saved_list(@user, @page).paginate(page: @page, per_page: 15))
  end

  def create
    @saved_listing = @user.saved_listings.build pixi_id: params[:id]
    respond_with(@saved_listing) do |format|
      if @saved_listing.save
        format.json { render json: {saved_listing: @saved_listing} }
      else
        format.json { render json: { errors: @saved_listing.errors.full_messages }, status: 422 }
      end
      reload_data
    end
  end

  def destroy
    @saved_listing = @user.saved_listings.find_by_pixi_id params[:id]
    respond_with(@saved_listing) do |format|
      if @saved_listing.destroy
        format.json { render json: {head: :ok} }
      else
        format.json { render json: { errors: @saved_listing.errors.full_messages }, status: 422 }
      end
      reload_data
    end
  end

  private

  def reload_data
    @listing = @saved_listing.listing.reload
  end

  def load_data
    @page = params[:page] || 1
    @status = NameParse::transliterate params[:status] if params[:status]
  end
end
