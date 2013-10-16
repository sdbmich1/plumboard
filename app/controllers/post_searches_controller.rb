require 'will_paginate/array' 
class PostSearchesController < ApplicationController
  include PointManager
  before_filter :authenticate_user!
  after_filter :add_points, only: [:index]
  autocomplete :post, :content, :full => true
  respond_to :html, :js, :mobile

  def index
    @posts = Post.search query, star: true, page: page unless query.blank?
  end

  protected

  # wrap query text for special characters
  def query
    @query = Riddle::Query.escape params[:search]
  end  

  def page
    @page = params[:page] || 1
  end

  def add_points
    PointManager::add_points @user, 'fpx'
  end

  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.get_posts @user.id
  end
end
