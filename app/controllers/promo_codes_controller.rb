require 'will_paginate/array' 
class PromoCodesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_promo, only: [:edit, :show, :update, :destroy]
  before_filter :load_promos, only: [:index]
  respond_to :html, :js, :mobile, :json

  def index
    respond_with @promos
  end

  def new
    respond_with(@promo = PromoCode.new(owner_id: params[:uid]))
  end

  def edit
    respond_with(@promo)
  end

  def update
    @promo.pictures.build.photo = File.new params[:file].tempfile if params[:file]
    respond_with(@promo) do |format|
      if @promo.update_attributes(params[:promo_code])
        format.json { render json: {promo_code: @promo} }
      else
        format.json { render json: { errors: @promo.errors.full_messages }, status: 422 }
      end
    end
  end

  def show
    respond_with(@promo)
  end

  def destroy
    respond_with(@promo) do |format|
      if @promo.destroy  
        format.html { redirect_to promo_codes_path }
	format.json { head :ok }
      else
        format.html { render action: :show, error: "Promo was not removed. Please try again." }
        format.json { render json: { errors: @promo.errors.full_messages }, status: 422 }
      end
    end
  end

  def create
    @promo = PromoCode.new params[:promo_code]
    @promo.pictures.build.photo = File.new params[:file].tempfile if params[:file]
    respond_with(@promo) do |format|
      if @promo.save
        flash[:notice] = 'Your promo has been saved.'
        format.json { render json: {promo_code: @promo} }
      else
        format.html { render :new }
        format.json { render json: { errors: @promo.errors.full_messages }, status: 422 }
      end
    end
  end

  protected

  # load promo
  def load_promo
    @promo = PromoCode.find params[:id] rescue nil
  end

  def load_promos
    items = params[:zip].nil? ? PromoCode.get_user_promos(@usr.id) : PromoCode.get_local_promos(params[:zip])
    @promos = items.paginate(page: params[:page], per_page: 15)
  end
end
