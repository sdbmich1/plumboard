class PagesController < ApplicationController
  before_filter :load_data, only: [:home]
  include PointManager
  layout :page_layout

  def home
    @listings = Listing.active.paginate(page: @page, per_page: @per_page)
    @leaders = PointManager::daily_leaderboard 
  end

  def index
    @listings = Listing.active.where("created_at > ?", Time.at(params[:after].to_i + 1))
  end

  protected

  def page_layout
    action_name == 'home' ? 'pages' : 'application'
  end

  def load_data
    @page = params[:page] || 1
    @per_page = params[:per_page] || 5
  end
end
