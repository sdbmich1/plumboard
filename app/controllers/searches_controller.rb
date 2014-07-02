require 'will_paginate/array' 
class SearchesController < ApplicationController
  before_filter :load_data, :get_location
  after_filter :add_points, only: [:index]
  autocomplete :listing, :title, :full => true
  include PointManager, LocationManager
  layout :page_layout
  respond_to :json, :html, :js, :mobile

  def index
    @listings = Listing.search query, search_options unless query.blank?
    respond_with(@listings)
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
    PointManager::add_points @user, 'fpx' if signed_in?
  end

  def site
    @site = LocationManager::get_site_list(@loc)
  end

  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.get_by_site(site)
  end
 
  def load_data
    @cat, @loc, @page = params[:cid], params[:loc], params[:page] || 1
  end

  # specify default search location based on user location
  def get_location
    @lat, @lng = LocationManager::get_lat_lng request.remote_ip rescue nil
    @loc_name = LocationManager::get_loc_name request.remote_ip, @loc
  end

  # dynamically define search options based on selections
  def search_options
    unless @loc.blank?
      @cat.blank? ? {:include => [:pictures, :site, :category], with: {site_id: site}, star: true, page: @page} : 
        {:include => [:pictures, :site, :category], with: {category_id: @cat, site_id: site}, star: true, page: @page}
    else
      unless @cat.blank?
        {:include => [:pictures, :site, :category], with: {category_id: @cat}, geo: [@lat, @lng], order: "geodist ASC, @weight DESC", 
	  star: true, page: @page}
      else
        @lat.blank? ? {:include => [:pictures, :site, :category], star: true, page: @page} : 
	  {:include => [:pictures, :site, :category], geo: [@lat, @lng], order: "geodist ASC, @weight DESC", star: true, page: @page}
      end
    end
  end
end
