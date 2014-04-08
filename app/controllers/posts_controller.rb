require 'will_paginate/array' 
class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :unread, :sent, :reply, :show]
  before_filter :mark_post, only: [:reply]
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def index
    @posts = @user.incoming_posts.paginate(page: @page, per_page: @per_page)
    respond_with(@posts) do |format|
      format.json { render json: {posts: @posts} }
    end
  end

  def reply
    @post = Post.new params[:post]
    respond_with(@post) do |format|
      if @post.save
        @posts = @user.reload.incoming_posts.paginate(page: @page, per_page: @per_page) 
        format.json { render json: {posts: @posts} }
      else
        format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
      end
    end
  end

  def show
    @posts = @user.incoming_posts.paginate(page: @page, per_page: @per_page)
    respond_with(@posts) do |format|
      format.json { render json: {posts: @posts} }
    end
  end

  def mark
    Post.mark_as_read! :all, :for => @user
  end

  def sent
    @posts = @user.posts.paginate(page: @page, per_page: @per_page)
    respond_with(@posts) do |format|
      format.json { render json: {posts: @posts} }
    end
  end

  def create
    @post = Post.new params[:post]
    respond_with(@post) do |format|
      if @post.save
	reload_data params[:post][:pixi_id]
        format.json { render json: {post: @post} }
      else
        format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @post = Post.find params[:id]
    @post.destroy  
    respond_with(@post)
  end
   
  private

  def page_layout
    mobile_device? && %w(index sent).detect{|x| action_name == x} ? 'form' : 'application'
  end

  def mark_post
    @old_post = Post.find params[:id]
    @old_post.mark_as_read! for: @user if @old_post
  end

  def load_data
    @page = params[:page] || 1
    @per_page = params[:per_page] || 5
  end

  def reload_data pid
    @listing = Listing.find_by_pixi_id pid
    @comments = @listing.comments.paginate page: @page, per_page: PIXI_COMMENTS if @listing
    @user.pixi_wants.create(pixi_id: pid) # add to user's wanted list
  end
end
