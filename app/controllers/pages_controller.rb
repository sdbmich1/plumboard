class PagesController < ApplicationController
  before_filter :load_data, only: [:help, :home, :location_name, :location_id]
  layout :page_layout
  respond_to :html, :json, :js, :mobile
  
  def help
  end

  def home
    respond_to do |format|
      format.any { render 'home', :formats => [:html] }
    end
  end

  def about
  end

  def privacy
  end

  def terms
  end

  def howitworks
  end

  def giveaway
  end

  def location_name
    respond_with(@home.site)
  end

  def location_id
    respond_with(@home.loc_id(params[:zip]))
  end

  protected

  def page_layout
    action_name == 'home' ? 'pages' : 'about'
  end

  def load_data
    @home = PageFacade.new(1, PIXI_DISPLAY_AMT)
  end
end
