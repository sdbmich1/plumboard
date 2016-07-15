class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: %i(show edit update destroy)
  before_filter :load_vars, :set_user
  respond_to :html, :json, :js
  layout :page_layout

  def create
    @sub = Subscription.new(params[:subscription]).add_card_account(params)
    respond_with(@sub) do |format|
      if @sub.save && @sub.add_subscription
        format.html { redirect_to subscriptions_path }
        format.json { render json: { sub: @sub } }
      else
        format.html { render action: :new, error: @sub.errors.full_messages }
        format.json { render json: { errors: @sub.errors.full_messages }, status: 422 }
      end
    end
  end

  def new
    respond_with(@sub = Subscription.load_new(params[:plan_id], @user))
  end

  def show
    respond_with(@sub)
  end

  def edit
    respond_with(@sub)
  end

  def update
    respond_with(@sub) do |format|
      if @sub.update_subscription(params)
        format.html { redirect_to subscriptions_path }
        format.json { render json: { sub: @sub } }
      else
        format.html { render action: :edit, error: @sub.errors.full_messages }
        format.json { render json: { errors: @sub.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    respond_with(@sub) do |format|
      if @sub.cancel_subscription
        format.html { redirect_to subscriptions_path }
        format.json { render json: { sub: @sub } }
      else
        format.html { render action: :index, error: @sub.errors.full_messages }
        format.json { render json: { errors: @sub.errors.full_messages }, status: 422 }
      end
    end
  end

  def index
    respond_with(@subs = Subscription.sub_list(@user, @adminFlg).paginate(page: params[:page], per_page: 15))
  end

  protected

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def load_data
    @sub = Subscription.find_by_id(params[:id])
  end

  def set_user
    @usr = params[:uid].blank? ? @user : User.find(params[:uid])
  end

  def load_vars
    @adminFlg = params[:adminFlg].try(:to_bool) || false
  end
end
