require 'will_paginate/array' 
class AdvancedSearchesController < ApplicationController
  before_filter :authenticate_user!, :load_query
  after_filter :add_points, only: [:index]
  autocomplete :listing, :title, :full => true
  autocomplete :site, :name, :full => true
  include PointManager

  def index
    @listings = Listing.search query, star: true, with: { category_id: params[:category_id] }, geo: [@lat, @lng], 
      order: "geodist ASC, @weight DESC", page: page unless query.blank?
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

  def load_query
    if params[:location]
      site = Site.find params[:location]
      @lat, @lng = site.contacts.lat, site.contacts.lng
    else
      @lat, @lng = request.location.latitude, request.location.longitude
    end
  end
end
