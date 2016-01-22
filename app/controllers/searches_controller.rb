require 'will_paginate/array' 
class SearchesController < ApplicationController
  before_filter :load_data, :load_search
  after_filter :add_points, only: [:index]
  autocomplete :listing, :title, :full => true
  include PointManager, LocationManager
  layout :page_layout
  respond_to :html, :json, :js, :mobile

  def index
    respond_with(@listings) do |format|
      format.js {}
      format.json { render json: {listings: @listings.to_json, sellers: @sellers.to_json} }
    end
  end

  protected

  def page_layout
    'listings'
  end

  # wrap query text for special characters
  def query
    @query = Riddle::Query.escape params[:search]
  end  

  def add_points
    PointManager::add_points @user, 'fpx' if signed_in? && @listings
  end

  def site
    @site = LocationManager::get_site_list(@loc)
  end

  def get_autocomplete_items(parameters)
    super(parameters).get_by_site(site) rescue nil
  end
 
  def load_data
    @cat, @loc, @page = params[:cid], params[:loc], params[:page] || 1
  end

  # dynamically define search options based on selections
  def search_options
    SearchBuilder.new(@cat, @loc, @page, request.remote_ip).search_options(@url, site)
  end

  def load_search
    @listings = Listing.search(query, search_options) rescue nil 
    load_sellers @listings
  end

  def load_sellers items
    @sellers = User.get_sellers(items) 
  end
end
