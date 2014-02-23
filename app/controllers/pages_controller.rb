class PagesController < ApplicationController
  respond_to :html, :json, :js, :mobile
  layout :page_layout
  
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

  protected

  def page_layout
    action_name == 'home' ? 'pages' : 'about'
  end
end
