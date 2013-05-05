class SearchesController < ApplicationController
  include PointManager
  before_filter :authenticate_user!
  after_filter :add_points, only: [:index]
  require 'will_paginate/array' 

  def index
    @listings = Listing.search query, page: page unless query.blank?
  end

  protected

  def query
    @query = Riddle::Query.escape params[:search]
  end  

  def page
    @page = params[:page] || 1
  end

  def add_points
     PointManager::add_points @user, 'fpx'
  end
end
