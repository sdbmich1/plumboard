require 'will_paginate/array' 
class SearchesController < ApplicationController
  before_filter :load_data
  before_filter :load_job, only: [:jobs]
  before_filter :pxb_url, only: [:biz, :member] 
  before_filter :load_url_data, only: [:biz, :member, :jobs]
  after_filter :add_points, only: [:index, :biz, :member]
  after_filter :set_location, only: [:biz, :member]
  autocomplete :listing, :title, :full => true
  include PointManager, LocationManager
  layout :page_layout
  respond_to :json, :html, :js, :mobile

  def index
    respond_with(@listings = Listing.search(query, search_options) rescue nil) 
  end

  def jobs
    respond_with(@listings)
  end

  def biz
    respond_with(@listings)
  end

  def member
    respond_with(@listings)
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

  def load_job
    params[:search] = 'Pixiboard'
    @cat = Category.get_by_name('Jobs') 
  end

  def pxb_url
    @url = request.original_url.to_s.split('/')[4]
  end

  def get_autocomplete_items(parameters)
    super(parameters).get_by_site(site) rescue nil
  end
 
  def load_data
    @cat, @loc, @url, @page = params[:cid], params[:loc], params[:url], params[:page] || 1
  end

  # dynamically define search options based on selections
  def search_options
    SearchBuilder.new(@cat, @loc, @page, request.remote_ip).search_options(@url, site)
  end

  def load_url_data
    @listings = Listing.search(query, :sql=>{:include=>[:pictures, :site, :category, :job_type]}, :page => @page) rescue nil 
  end

  def set_location
    session[:back_to] = request.fullpath
  end
end
