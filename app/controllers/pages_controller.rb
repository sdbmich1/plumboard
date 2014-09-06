class PagesController < ApplicationController
  respond_to :html, :json, :js, :mobile
  layout :page_layout
  include LocationManager
  
  def help
    @faqs = Faq.active
  end

  def home
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
    @region, @loc_name = LocationManager::get_region params[:loc_name]
    respond_with(@loc_name)
  end

  protected

  def page_layout
    action_name == 'home' ? 'pages' : 'about'
  end
end
