require 'will_paginate/array' 
class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :unread, :sent]
  before_filter :mark_post, only: [:reply]

  def index
    @posts = @user.incoming_posts.paginate(page: @page)
  end

  def reply
    @post = Post.new params[:post]
    if @post.save
      flash.now[:notice] = "Successfully sent post."
      @posts = Post.get_posts(@user).paginate(page: @page)
    end
  end

  def sent
    @posts = @user.posts.paginate(page: @page)
  end

  def create
    @listing = Listing.find_by_pixi_id params[:post][:pixi_id]
    @post = Post.new params[:post]
    if @post.save
      flash[:notice] = "Successfully created post."
      @post = Post.load_new @listing
    end
  end

  def destroy
    @post = Post.find params[:id]
  end
   
  private

  def mark_post
    @old_post = Post.find params[:id]
    @old_post.mark_as_read! for: @user if @old_post
  end

  def load_data
    @page = params[:page] || 1
  end
end
