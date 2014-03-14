require 'will_paginate/array' 
class InvoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :incoming, :paid, :create]
#  before_filter :set_params, only: [:create, :update]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def new
    @invoice = Invoice.load_new @user
  end
   
  def index
    @invoices = @user.invoices.paginate(page: @page)
    respond_with(@invoices) do |format|
      format.json { render json: {invoices: @invoices} }
    end
  end
   
  def received
    @invoices = @user.received_invoices.paginate(page: @page)
    respond_with(@invoices) do |format|
      format.json { render json: {invoices: @invoices} }
    end
  end

  def show
    @invoice = Invoice.find params[:id]
    respond_with(@invoice) do |format|
      format.json { render json: {user: @user, invoice: @invoice} }
    end
  end

  def edit
    @invoice = Invoice.find params[:id]
    respond_with(@invoice)
  end

  def update
    @invoice = Invoice.find params[:id]
    respond_with(@invoice) do |format|
      if @invoice.update_attributes(params[:invoice])
        @invoices = Invoice.get_invoices(@user).paginate(page: @page)
        format.json { render json: {invoice: @invoice} }
      else
        format.json { render json: { errors: @invoice.errors.full_messages }, status: 422 }
      end
    end
  end

  def create
    @invoice = @user.invoices.build params[:invoice]
    respond_with(@invoice) do |format|
      if @invoice.save
        @invoices = Invoice.get_invoices(@user).paginate(page: @page)
        format.json { render json: {invoice: @invoice} }
      else
        format.json { render json: { errors: @invoice.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @invoice = Invoice.find params[:id]
    if @invoice.destroy
      @invoices = Invoice.get_invoices(@user).paginate(page: @page)
    end  
    respond_with(@invoice)
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def load_data
    @page = params[:page] || 1
  end

  def set_params
    respond_to do |format|
      format.html 
      format.mobile 
      format.json { params[:invoice] = JSON.parse(params[:invoice]) }
    end
  end
end
