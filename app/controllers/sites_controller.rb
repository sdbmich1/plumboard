class SitesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  respond_to :html, :json, :js, :mobile

  def index
    respond_with(@sites = Site.get_by_type(@stype).paginate(page: @page, per_page: 15))
  end

  def loc_name
    @sites = Site.search query, star: true, :page => params[:page], :per_page => 10
    respond_to do |format|
      format.json { render json: @sites }
    end
  end

  private

  def load_data
    @stype, @page = params[:stype], params[:page]
  end 

  def query
    @query = Riddle::Query.escape params[:search]
  end 
end
