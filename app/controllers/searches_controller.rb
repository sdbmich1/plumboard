require 'will_paginate/array' 
class SearchesController < ApplicationController
  before_filter :load_data, :get_location
  after_filter :add_points, only: [:index]
  autocomplete :listing, :title, :full => true
  include PointManager
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
    @ip = Rails.env.development? || Rails.env.test? ? '24.4.199.34' : request.remote_ip
    @area = Geocoder.search(@ip)
    @lat, @lng = @area.first.latitude, @area.first.longitude rescue nil
  end

  # dynamically define search options based on selections
  def search_options
    unless @loc.blank?
      @cat.blank? ? {with: {site_id: @loc}, star: true, page: @page} : {with: {category_id: @cat, site_id: @loc}, star: true, page: @page}
    else
      unless @cat.blank?
        {with: {category_id: @cat}, geo: [@lat, @lng], order: "geodist ASC, @weight DESC", star: true, page: @page}
      else
        @lat.blank? ? {star: true, page: @page} : {geo: [@lat, @lng], order: "geodist ASC, @weight DESC", star: true, page: @page}
      end
    end
  end
end
