class PixiLikesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :mobile, :json

  def create
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
    @like = @user.pixi_likes.find_by_pixi_id pid rescue nil
    @saved = @user.saved_listings.find_by_pixi_id pid rescue nil
    @contact = @user.posts.find_by_pixi_id pid rescue nil
  end
end
