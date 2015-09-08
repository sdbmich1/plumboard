require 'will_paginate/array' 
class SitesController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index]
  respond_to :html, :json, :js, :mobile

  def index
    respond_with(@sites = Site.includes(:pictures).get_by_type(@stype, @status).paginate(page: @page, per_page: 15))
  end

  def loc_name
    @sites = Site.search query, star: true, :page => params[:page], :per_page => 10
    respond_to do |format|
      format.json { render json: @sites }
    end
  end

  def new
    @site = Site.new
    @contact = @site.contacts.build
  end

  def create
    @site = Site.new(params[:site])
    respond_with(@site) do |format|
      if @site.save_site
        format.json { render json: { site: @site } }
      else
        format.json { render json: { errors: @site.errors.full_messages }, status: 422 }
      end
    end
  end

  def show
    respond_with(@site = Site.find(params[:id]))
  end

  def edit
    respond_with(@site = Site.find(params[:id]))
  end

  def update
    respond_with(@site) do |format|
      if @site.update_attributes(params[:site])
        format.json { render json: { site: @site } }
      else
        format.json { render json: { errors: @site.errors.full_messages }, status: 422 }
      end
    end
  end

  private

  def load_data
    @stype, @status, @page = params[:stype] || 'region', params[:status], params[:page]
  end 

  def query
    @query = Riddle::Query.escape params[:search]
  end 
end
