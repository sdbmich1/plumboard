class PixiLikesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :mobile, :json

  def create
    @listing = Listing.find_by_pixi_id params[:id]
    @like = @user.pixi_likes.build pixi_id: params[:id]
    respond_with(@like) do |format|
      if @like.save
        reload_data params[:id]
        format.json { render json: {pixi_like: @like} }
      else
        format.json { render json: { errors: @like.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @listing = Listing.find_by_pixi_id params[:pixi_id]
    @like = @user.pixi_likes.find_by_pixi_id params[:pixi_id]
    respond_with(@like) do |format|
      if @like.destroy
	reload_data params[:pixi_id]
        format.json { render json: {head: :ok} }
      else
        format.json { render json: { errors: @like.errors.full_messages }, status: 422 }
      end
    end
  end

  protected

  def reload_data pid
    @listing = Listing.find_by_pixi_id pid
    @like = @user.pixi_likes.where(pixi_id: pid).first
    @saved = @user.saved_listings.where(pixi_id: pid).first
    @contact = @user.posts.where(pixi_id: pid).first
  end
end
