require 'will_paginate/array' 
class SearchesController < ApplicationController
  before_filter :authenticate_user!, :load_data, :get_location
  after_filter :add_points, only: [:index]
  autocomplete :listing, :title, :full => true
  include PointManager
  layout :page_layout

  def index
    @listings = Listing.search query, search_options unless query.blank?

    respond_to do |format|
      format.mobile { render :nothing => true }
      format.html { render :nothing => true }
      format.js 
    end
  end

  protected

  def page_layout
    'listings' if mobile_device? 
  end

  # wrap query text for special characters
  def query
    @query = Riddle::Query.escape params[:search]
  end  

  def add_points
    PointManager::add_points @user, 'fpx'
  end

  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active
  end
 
  def load_data
    @cat = params[:cid]
    @loc = params[:loc] if params[:loc]
    @page = params[:page] || 1
  end

  # specify default search location based on user location
  def get_location
    @lat, @lng = request.location.try(:latitude), request.location.try(:longitude) 
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
