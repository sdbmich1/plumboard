require 'will_paginate/array' 
class PixiPostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_permissions, only: [:index]
  before_filter :set_params, only: [:create, :update]
  before_filter :set_zip, only: [:new]
  before_filter :load_data, only: [:index, :seller, :pixter, :pixter_report]
  before_filter :ajax?, only: [:pixter_report]
  autocomplete :site, :name, full: true, scopes: [:cities]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  include ResetDate
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def new
    @post = PixiPost.load_new @user, @zip
    respond_with(@post)
  end

  def create
    @post = PixiPost.new params[:pixi_post]
    respond_with(@post) do |format|
      if @post.save
        format.json { render json: {post: @post} }
      else
        format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
      end
    end
  end

  def edit
    @post = PixiPost.find params[:id]
    respond_with(@post)
  end

  def update
    @post = PixiPost.find params[:id]
    respond_with(@post) do |format|
      if @post.update_attributes(params[:pixi_post])
        format.json { render json: {post: @post} }
      else
        format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
      end
    end
  end

  def show
    @post = PixiPost.find params[:id]
    respond_with(@post)
  end

  def index
    @posts = PixiPost.get_by_status(@status).paginate(page: @page)
    respond_with(@posts)
  end

  def destroy
    @post = PixiPost.find params[:id]
    respond_with(@post) do |format|
      if @post.destroy  
        format.html { redirect_to seller_pixi_posts_path(status: 'active') }
        format.mobile { redirect_to seller_pixi_posts_path(status: 'active') }
	      format.json { head :ok }
      else
        format.html { render action: :show, error: "PixiPost was not removed. Please try again." }
        format.mobile { render action: :show, error: "PixiPost was not removed. Please try again." }
        format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
      end
    end
  end

  def seller
    @posts = PixiPost.get_by_seller(@user).get_by_status(@status).paginate(page: @page)
    respond_with(@posts)
  end

  def pixter
    @posts = PixiPost.get_by_pixter(@user).get_by_status(@status).paginate(page: @page)
    respond_with(@posts)
  end

  def reschedule
    @post = PixiPost.reschedule params[:id]
    respond_with(@post)
  end

  def pixter_report
    @date_range, @pixter_id = params[:date_range], set_pixter_id
    @start_date, @end_date = ResetDate::get_date_range(@date_range)
    @pixi_posts = PixiPost.pixter_report(@start_date, @end_date, @pixter_id).paginate(page: @page, per_page: 15)
    respond_to do |format|
      format.html
      format.js
      format.csv {send_data PixiPost.to_csv(@pixi_posts), filename: 'pixter_report_' + Date.today.to_s + '.csv'}
    end
  end
  
  private
  # sets pixter_id for pixter_report based on admin / pixter?
  def set_pixter_id
    (!@user.is_pixter?) ? params[:pixter_id] : @user.id
  end

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def load_data
    @page = params[:page] || 1
    @status = params[:status]
  end

  def set_zip
    @zip = params[:zip]
  end

  def set_params
    respond_to do |format|
      format.html { params[:pixi_post] = ResetDate::reset_dates(params[:pixi_post], 'PixiPost') }
      format.json { params[:pixi_post] = JSON.parse(params[:pixi_post]) }
    end
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active rescue items
  end

  def check_permissions
    authorize! :manage, PixiPost
  end

  def ajax?
    @xhr_flag = request.xhr?
  end


end
