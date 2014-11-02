require 'will_paginate/array' 
class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:unread]
  before_filter :mark_post, only: [:mark_read]
  respond_to :html, :js, :xml, :json, :mobile
  layout :page_layout

  def mark
    Post.mark_as_read! :all, :for => @user
  end

  def create
    @conversation = Conversation.find(:first, :conditions => ["pixi_id = ? AND recipient_id = ? AND user_id = ? AND status = ?",
                                      params[:post][:pixi_id], params[:post][:recipient_id], params[:post][:user_id], 'active']) rescue nil
      
    if @conversation
      @post = @conversation.posts.build params[:post]
      respond_with(@post) do |format|
        if @post.save
          reload_data params[:post][:pixi_id]
          format.json { render json: {post: @post} }
        else
          format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
        end
      end
    else 
      flash[:error] = "Could not create new message, please try again."
      render :nothing => true
    end
  end

  def destroy
    @post = Post.find params[:id]
    @post.destroy  
    respond_with(@post)
  end

  # soft deletes a post
  def remove
    @post = Post.find params[:id]
    if @post.remove_post(@user)
      redirect_to set_redirect_path(params[:status]), notice: 'Message removed successfully' 
    else
      flash[:error] = "Post was not removed. Please try again."
    end
    render :nothing => true
  end

  def mark_read
  end
   
  private

  def page_layout
    mobile_device? && %w(index sent).detect{|x| action_name == x} ? 'form' : 'application'
  end

  def mark_post
    @old_post = Post.find params[:id]
    @old_post.mark_as_read! for: @user if @old_post && @old_post.unread?(@user)
  end

  def load_data
    @page = params[:page] || 1
    @per_page = params[:per_page] || 5
  end

  def reload_data pid
    @listing = Listing.find_pixi pid
    @comments = @listing.comments.paginate page: @page, per_page: PIXI_COMMENTS if @listing
    @user.pixi_wants.create(pixi_id: pid) # add to user's wanted list
  end

  def set_redirect_path status='received'
    @conversation = @post.conversation.reload
    if @conversation && @conversation.active_post_count(@user) > 0 
      @posts, @post = @conversation.posts.active_status(@user), @conversation.posts.build
      conversation_path(@conversation)
    else
      conversations_path(status: status)
    end
  end
end
