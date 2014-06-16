require 'will_paginate/array' 
class UserSearchesController < ApplicationController
  before_filter :authenticate_user!
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :js, :mobile, :json

  def index
    @users = User.search query, include: [:pictures, :preferences], star: true, page: page unless query.blank?
  end

  protected

  # wrap query text for special characters
  def query
    @query = Riddle::Query.escape params[:search_user]
  end  

  def page
    @page = params[:page] || 1
  end

  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active rescue items
  end
end
