require 'will_paginate/array' 
class PromoCodeSearchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, :load_search
  respond_to :html, :js, :mobile, :json

  def index
    respond_with @promos
  end

  def locate
    respond_with @promos
  end

  protected

  def load_search
    @promos = PromoCode.search(query, search_options).populate rescue nil 
  end

  # wrap query text for special characters
  def query
    @query = Riddle::Query.escape params[:search_txt]
  end  
 
  def load_data
    @loc, @page, @url = params[:loc], params[:page] || 1, params[:url]
  end

  def site
    @site = LocationManager::get_site_list(@loc)
  end

  # dynamically define search options based on selections
  def search_options
    if @url.nil?
      ModelSearchBuilder.new([:pictures, :user, :site], @page).search_options('site_id', site)
    else
      ModelSearchBuilder.new([:pictures, :user, :site], @page).search_options('url', @url)
    end
  end
end
