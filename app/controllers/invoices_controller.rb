require 'will_paginate/array' 
class InvoicesController < ApplicationController
  load_and_authorize_resource
  # skip_authorize_resource :only => [:new, :show, :create]
  before_filter :authenticate_user!
  # before_filter :check_permissions, only: [:create, :edit, :update, :destroy, :show]
  before_filter :load_data, only: [:index, :sent, :received]
  before_filter :set_params, only: [:create, :update]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def new
    @invoice = Invoice.load_new @user
  end
   
  def index
    @invoices = Invoice.all.paginate(page: @page)
    respond_with(@invoices) do |format|
      format.json { render json: {invoices: @invoices} }
    end
  end
   
  def sent
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
    @invoice = @user.invoices.reload.find params[:id]
    respond_with(@invoice) do |format|
      format.json { render json: {user: @user, invoice: @invoice} }
    end
  end

  def edit
    @invoice = @user.invoices.find params[:id]
    respond_with(@invoice)
  end

  def update
    @invoice = @user.invoices.find params[:id]
    respond_with(@invoice) do |format|
      if @invoice.update_attributes(params[:invoice])
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
        format.json { render json: {invoice: @invoice} }
      else
        format.json { render json: { errors: @invoice.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @invoice = @user.invoices.find params[:id]
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
    params[:invoice] = JSON.parse(params[:invoice]) if request.xhr?
  end

  def check_permissions
    authorize! :crud, Invoice
  end
end
