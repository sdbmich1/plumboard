require 'will_paginate/array' 
class InvoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :incoming, :paid, :create]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def new
    @invoice = @user.invoices.build
  end
   
  def index
    @invoices = @user.invoices.paginate(page: @page)
  end
   
  def received
    @invoices = @user.received_invoices.paginate(page: @page)
  end

  def show
    @invoice = Invoice.find params[:id]
  end

  def edit
    @invoice = Invoice.find params[:id]
  end

  def update
    @invoice = Invoice.find params[:id]
    if @invoice.update_attributes(params[:invoice])
      @invoices = Invoice.get_invoices(@user).paginate(page: @page)
    end
    respond_with(@invoice) do |format|
      format.html { redirect_to invoices_url }
    end
  end

  def create
    @invoice = @user.invoices.build params[:invoice]
    if @invoice.save
      @invoices = Invoice.get_invoices(@user).paginate(page: @page)
    end  
    respond_with(@invoice) do |format|
      format.html { redirect_to invoices_url }
    end
  end

  def destroy
    @invoice = Invoice.find params[:id]
    if @invoice.destroy
      @invoices = Invoice.get_invoices(@user).paginate(page: @page)
    end  
  end

  # get pixi price
  def get_pixi_price
    @price = Listing.find_by_pixi_id(params[:pixi_id]).price
  end

  private

  def page_layout
    mobile_device? && %w(index received).detect{|x| action_name == x} ? 'form' : 'application'
  end

  def load_data
    @page = params[:page] || 1
  end
end
