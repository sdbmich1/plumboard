require 'will_paginate/array' 
class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:remove, :mark_read]
  respond_to :html, :js, :xml, :json, :mobile
  layout :page_layout

  def mark
    Post.mark_as_read! :all, :for => @user
  end

  # soft deletes a post
  def remove
    respond_with(@post) do |format|
      if @post.remove_post(@user)
        flash[:notice] = 'Message removed successfully'
	format.js { set_redirect_path(params[:status]) }
        format.json { render json: @post }
      else
        format.js {flash[:error] = "Post was not removed. Please try again."}
        format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
      end
    end
  end

  def mark_read
    @post.mark_as_read! for: @user if @post && @post.unread?(@user)
  end
   
  private

  def set_redirect_path status
    if @post.reload.conversation.active_post_count(@user) > 0 
      redirect_to @post.conversation and return
    else
      render :js => "window.location = '#{conversations_path(:status=>status)}'"
    end
  end

  def page_layout
    mobile_device? && %w(index sent).detect{|x| action_name == x} ? 'form' : 'application'
  end

  def load_data
    @post = Post.find params[:id]
  end
end
