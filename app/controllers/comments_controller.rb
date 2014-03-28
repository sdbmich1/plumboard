require 'will_paginate/array' 
class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:create]
  respond_to :html, :js, :mobile, :json
  layout :page_layout

  def create
    @comment = Comment.new params[:comment]
    respond_with(@comment) do |format|
      if @comment.save
        reload_data
        format.json { render json: {comments: @comments} }
      else
        format.json { render json: { errors: @comment.errors.full_messages }, status: 422 }
      end
    end
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def load_data
    @page = params[:page] || 1
    @per_page = params[:per_page] || PIXI_COMMENTS
  end

  def reload_data 
    @listing = Listing.find_by_pixi_id params[:comment][:pixi_id]
    @comments = @listing.comments.paginate page: @page, per_page: @per_page if @listing
    @comment = @listing.comments.build
  end

end
