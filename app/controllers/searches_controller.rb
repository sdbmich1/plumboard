require 'will_paginate/array' 
class SearchesController < ApplicationController
  before_filter :authenticate_user!, :get_location
  after_filter :add_points, only: [:index]
  autocomplete :listing, :title, :full => true
  include PointManager

  def index
    @listings = Listing.search query, geo: [@lat, @lng], order: "geodist ASC, @weight DESC", star: true, page: page unless query.blank?
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
    items = items.active
  end
 
  # specify default search location based on user location
  def get_location
    @lat, @lng = request.location.latitude, request.location.longitude
  end
end
