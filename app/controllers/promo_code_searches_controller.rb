require 'will_paginate/array' 
class PromoCodeSearchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  before_filter :set_params, only: [:locate]
  before_filter :load_search
  respond_to :html, :js, :mobile, :json

  def index
    send_result
  end

  def locate
    send_result
  end

  protected

  def load_search
    @promos = PromoCode.search(query, search_options).populate rescue nil 
  end

  # wrap query text for special characters
  def query
    @query = Riddle::Query.escape @search
  end  
 
  def load_data
    @loc, @page, @url, @search = params[:loc], params[:page] || 1, params[:url], params[:search]
  end

  def site
    @site = LocationManager::get_site_list(@loc)
  end

  # parse fields to adjust formatting
  def set_params
    items = RecursiveOpenStruct.new(params[:locate])
    @search, @loc, @url, @sz = items.search, items.loc, items.url, num_rows
  end

  # dynamically define search options based on selections
  def search_options
    if @url.blank?
      ModelSearchBuilder.new([:pictures, :user, :site], @page).search_options('site_id', site)
    else
      ModelSearchBuilder.new([:pictures, :user, :site], @page).search_options('url', @url)
    end
  end

  def send_result
    respond_with(@promos) do |format|
      format.json { render json: @promos }
    end
  end
end
