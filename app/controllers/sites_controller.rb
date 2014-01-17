class SitesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json, :js, :mobile

  def index
    respond_with(@sites = Site.all)
  end

  def loc_name
    @sites = Site.search query, star: true, :page => params[:page], :per_page => 10
    respond_to do |format|
      format.json { render json: @sites }
    end
  end

  private

  def query
    @query = Riddle::Query.escape params[:search]
  end 
end
