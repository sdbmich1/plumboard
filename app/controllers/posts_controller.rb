require 'will_paginate/array' 
class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :mark_post, only: [:mark_read]
  respond_to :html, :js, :xml, :json, :mobile
  layout :page_layout

  def mark
    Post.mark_as_read! :all, :for => @user
  end

  # soft deletes a post
  def remove
    @post = Post.find params[:id]
    if @post.remove_post(@user)
      redirect_to set_redirect_path(params[:status]), notice: 'Message removed successfully' 
    else
      flash[:error] = "Post was not removed. Please try again."
    end
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
end
