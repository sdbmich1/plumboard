require 'will_paginate/array'
class SiteSearchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  respond_to :html, :js, :mobile, :json

  def index
    @sites = Site.search query, search_options
  end

  protected

  # wrap query text for special characters
  def query
    Riddle::Query.escape params[:search_txt]
  end
 
  def load_data
    @stype, @page = params[:stype], params[:page] || 1
  end

  # dynamically define search options based on selections
  def search_options
    ModelSearchBuilder.new([:pictures], @page).search_options('site_type_code', @stype)
  end
end
