require 'will_paginate/array' 
class SearchesController < ApplicationController
  before_filter :authenticate_user!, :load_data, :get_location
  after_filter :add_points, only: [:index]
  autocomplete :listing, :title, :full => true
  include PointManager

  def index
    @listings = Listing.search query, search_options unless query.blank?
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
 
  def load_data
    @cat = params[:search_category_id]
    @loc = params[:search_site_id] if params[:search_site_id]
  end

  # specify default search location based on user location
  def get_location
    @lat, @lng = request.location.latitude, request.location.longitude 
  end

  # dynamically define search options based on selections
  def search_options
    unless @loc.blank?
      @cat.blank? ? {with: {site_id: @loc}, star: true, page: @page} : {with: {category_id: @cat, site_id: @loc}, star: true, page: @page}
    else
      unless @cat.blank?
        {with: {category_id: @cat}, geo: [@lat, @lng], order: "geodist ASC, @weight DESC", star: true, page: @page}
      else
        {geo: [@lat, @lng], order: "geodist ASC, @weight DESC", star: true, page: @page}
      end
    end
  end
end
