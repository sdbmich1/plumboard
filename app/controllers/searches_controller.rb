class SearchesController < ApplicationController
  before_filter :authenticate_user!
  require 'will_paginate/array' 

  def index
    @listings = Listing.search query, page: page unless query.blank?
  end

  protected

  def query
    @query = params[:search]
  end  

  def page
    @page = params[:page] || 1
  end
end
