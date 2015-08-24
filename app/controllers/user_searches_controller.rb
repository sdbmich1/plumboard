require 'will_paginate/array' 
class UserSearchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  respond_to :html, :js, :mobile, :json

  def index
    @users = User.search query, search_options
  end

  protected

  # wrap query text for special characters
  def query
    @query = Riddle::Query.escape params[:search_txt]
  end  
 
  def load_data
    @utype, @page = params[:utype], params[:page] || 1
  end

  # dynamically define search options based on selections
  def search_options
    ModelSearchBuilder.new([:pictures, :user_type, :preferences], @page).search_options('user_type_code', @utype)
  end
end
