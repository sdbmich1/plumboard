require 'will_paginate/array' 
class PromoCodeSearchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  respond_to :html, :js, :mobile, :json

  def index
    @promos = PromoCode.search query, search_options
  end

  protected

  # wrap query text for special characters
  def query
    @query = Riddle::Query.escape params[:search_txt]
  end  
 
  def load_data
    @loc, @page = params[:loc], params[:page] || 1
  end

  # dynamically define search options based on selections
  def search_options
    ModelSearchBuilder.new([:pictures, :user, :site], @page).search_options('site_id', @loc)
  end
end
