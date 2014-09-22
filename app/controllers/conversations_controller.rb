require 'will_paginate/array' 
class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :unread, :sent, :reply, :show]
  before_filter :mark_post, only: [:show]
  respond_to :html, :js, :xml, :json, :mobile
  layout :page_layout

  def index
    respond_with(@conversations = Conversation.get_specific_conversations(@user, "received").paginate(page: @page, per_page: @per_page))
  end

  def create
    @conversation = Conversation.new params[:conversation]
    respond_with(@conversation) do |format|
      @post = @conversation.posts.build params[:post]
      if @conversation.save
        format.json { render json: {conversation: @conversation} }
      else
        format.json { render json: { errors: @conversation.errors.full_messages }, status: 422 }
      end
    end
  end

  def sent
    respond_with(@conversations = Conversation.get_specific_conversations(@user, "sent").paginate(page: @page, per_page: @per_page))
  end

  def destroy
    @conversation = Conversation.find params[:id]
    @conversation.destroy  
    respond_with(@conversation)
  end

  def remove 
    @conversation = Conversation.find params[:id]

    if Conversation.remove_conv(@conversation, @user)
      redirect_to conversations_path
    else
      flash[:error] = "Conversation was not removed. Please try again."
      render :nothing => true
    end
  end

  def reply 
    @conversation = Conversation.find(params[:id])

    if @conversation
      respond_with(@conversation) do |format|
        @post = @conversation.posts.build(params[:post])
        if @conversation.save
          @conversations = Conversation.get_specific_conversations(@user, "received").paginate(page: @page, per_page: @per_page)
          format.json { render json: {conversation: @conversation} }
        else
          format.json { render json: { errors: @conversation.errors.full_messages }, status: 422 }
        end
      end
    end
  end

  def show
    @conversation = Conversation.inc_show_list.find(params[:id])
    if @conversation
      @posts, @post = @conversation.posts, @conversation.posts.build
      respond_with(@conversation)
    end
  end

  private

  def page_layout
    mobile_device? && %w(index sent).detect{|x| action_name == x} ? 'form' : 'application'
  end

  def load_data
    @page = params[:page] || 1
    @per_page = params[:per_page] || 10
  end

  def mark_post
    @conversation = Conversation.find params[:id]
    if @conversation
      @conversation.posts.each do |post|
        post.mark_as_read! for: @user if post
      end
    end
  end
end
