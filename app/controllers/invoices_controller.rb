require 'will_paginate/array' 
class InvoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :incoming, :paid, :create]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :js

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
      flash[:notice] = "Successfully updated invoice." 
      @invoices = Invoice.get_invoices(@user).paginate(page: @page)
    end
  end

  def create
    @invoice = @user.invoices.build params[:invoice]
    if @invoice.save
      flash.now[:notice] = "Successfully created invoice." 
      @invoices = Invoice.get_invoices(@user).paginate(page: @page)
    end  
  end

  def destroy
    @invoice = Invoice.find params[:id]
    if @invoice.destroy
      flash[:notice] = "Successfully removed invoice." 
      @invoices = Invoice.get_invoices(@user).paginate(page: @page)
    end  
  end

  # get pixi price
  def get_pixi
    @price = Listing.find_by_pixi_id(params[:pixi_id]).price
  end

  private

  def load_data
    @page = params[:page] || 1
  end
end
