class PagesController < ApplicationController
  layout :page_layout

  def home
  end

  def index
  end

  protected

  def page_layout
    action_name == 'home' ? 'pages' : 'about'
  end
end
