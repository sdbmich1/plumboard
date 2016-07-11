require 'will_paginate/array' 
class ConversationsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :reply, :show, :remove]
  before_filter :load_convo, only: [:reply, :destroy, :remove] 
  before_filter :ajax?, only: [:create, :update]
  after_filter :mark_message, only: [:show]
  respond_to :html, :js, :xml, :json, :mobile
  layout :page_layout

  def index
    respond_with(@conversation.conversations)
  end

  def create
    @conversation = Conversation.new params[:conversation]
    respond_with(@conversation) do |format|
      if @conversation.save
        format.json { render json: {conversation: @conversation} }
      else
        format.json { render json: { errors: @conversation.errors.full_messages }, status: 422 }
      end
    end
  end

  def update
    @conversation = Conversation.find(params[:id])
    respond_with(@conversation) do |format|
      if @conversation.update_attributes(params[:conversation])
        format.json { render json: {conversation: @conversation} }
      else
        format.json { render json: { errors: @conversation.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @conversation.destroy  
    respond_with(@conversation)
  end

  def remove 
    respond_with(@conversation) do |format|
      if Conversation.remove_conv(@conversation, @user)
        format.js { redirect_to conversations_path(status: @status) }
        format.html { redirect_to conversations_path(status: @status)}
        format.json { render json: {conversation: @conversation} }
      else
        flash[:error] = "Conversation was not removed. Please try again."
        render :action => :index
	format.js {}
        format.json { render json: { errors: @conversation.errors.full_messages }, status: 422 }
      end
    end
  end

  def reply 
    respond_with(@conversation) do |format|
      if @conversation.posts.create(params[:post])
        @conversation = @conversation.reload
        format.json { render json: {conversation: @conversation} }
      else
        format.json { render json: { errors: @conversation.errors.full_messages }, status: 422 }
      end
    end
  end

  def show
    respond_with(@conversation = Conversation.inc_show_list.find(params[:id])) do |format|
      format.json { render json: @conversation.as_json(user: @user) }
    end
  end

  private

  def page_layout
    mobile_device? && %w(index sent).detect{|x| action_name == x} ? 'form' : 'application'
  end

  def load_data
    @conversation = ConversationFacade.new(params)
    # @page, @per_page, @status = params[:page] || 1, params[:per_page] || 10, params[:status] || 'received'
  end

  def load_convo
    @conversation = Conversation.find(params[:id])
  end

  def ajax?
    request.xhr?
  end

  def mark_message
    @conversation.mark_all_posts(@user) if @conversation
  end
end
