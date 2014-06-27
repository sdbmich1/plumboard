class InquiriesController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :show, :edit, :update]
  before_filter :load_data, only: [:show, :edit, :update, :destroy]
  respond_to :html, :json, :js, :mobile
  layout :page_layout
  
  def new
    @inquiry = signed_in? ? @user.inquiries.build : Inquiry.new
    @source = params[:source]
  end

  def update
    @inquiry.update_attributes(params[:inquiry])
    respond_with @inquiry
  end

  def index
    respond_with(@inquiries = Inquiry.get_by_contact_type(params[:ctype]).paginate(page: @page))
  end
  
  def closed
    respond_with(@inquiries = Inquiry.get_by_status('closed').paginate(page: @page))
  end

  def create
    @inquiry = Inquiry.new params[:inquiry]
    respond_with(@inquiry) do |format|
      if @inquiry.save 
	format.html { redirect_to get_root_path, notice: 'Your inquiry was successfully submitted.' }
	format.mobile { redirect_to get_root_path }
        format.json { render json: {inquiry: @inquiry} }
      else
        format.json { render json: { errors: @inquiry.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @inquiry.destroy
    respond_with(@inquiry)
  end

  protected

  def page_layout
    action_name == 'new' ? 'about' : 'application'
  end

  def load_data
    @inquiry = Inquiry.find params[:id]
  end

end
