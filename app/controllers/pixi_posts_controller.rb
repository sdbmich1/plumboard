require 'will_paginate/array' 
class PixiPostsController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]
  before_filter :check_permissions, only: [:index]
  before_filter :set_params, only: [:create, :update]
  before_filter :set_zip, only: [:new]
  before_filter :load_data, only: [:index, :seller, :pixter, :pixter_report]
  before_filter :load_post, only: [:show, :edit, :update, :destroy]
  before_filter :init_vars, only: [:pixter_report]
  after_filter :set_session, only: [:show]
  after_filter :set_uid, only: [:create]
  autocomplete :site, :name, full: true, scopes: [:cities]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  include ResetDate
  respond_to :html, :js, :json, :mobile, :csv
  layout :page_layout

  def new
    respond_with(@post = PixiPost.load_new(@user, @zip))
  end

  def create
    @post = PixiPost.add_post params[:pixi_post], @user
    respond_with(@post) do |format|
      if @post.save
        format.json { render json: {post: @post} }
      else
        format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
      end
    end
  end

  def edit
    respond_with(@post)
  end

  def update
    respond_with(@post) do |format|
      if @post.update_attributes(params[:pixi_post])
        format.json { render json: {post: @post} }
      else
        format.json { render json: { errors: @post.errors.full_messages }, status: 422 }
      end
    end
  end

  def show
    respond_with(@post)
  end

  def index
    respond_with(@posts = PixiPost.get_by_status(@status).paginate(page: @page))
  end

  def destroy
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
    respond_with(@posts = PixiPost.get_by_seller(@user).get_by_status(@status).paginate(page: @page))
  end

  def pixter
    respond_with(@posts = PixiPost.get_by_pixter(@user).get_by_status(@status).paginate(page: @page))
  end

  def reschedule
    respond_with(@post = PixiPost.reschedule(params[:id]))
  end

  def pixter_report
    @unpaginated_posts = PixiPost.pixter_report(@start_date, @end_date, @pixter_id)
    respond_with(@posts = @unpaginated_posts.paginate(page: @page, per_page: 15)) { |format| render_csv format }
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
    @page, @status = params[:page] || 1, params[:status]
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
    super(parameters).active rescue nil
  end

  def check_permissions
    authorize! :manage, PixiPost
  end

  def init_vars
    @date_range, @pixter_id = params[:date_range], set_pixter_id
    @start_date, @end_date = ResetDate::get_date_range(@date_range)
  end

  def load_post
    @post = PixiPost.find params[:id]
  end

  def render_csv format
    format.csv { send_data(render_to_string(csv: @unpaginated_posts), disposition: "attachment; filename=#{PixiPost.filename}.csv") }
  end

  def set_uid
    ControllerManager::set_uid session, @post
  end
end
