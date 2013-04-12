class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find params[:id]
    @photo = @user.pictures
  end

  def edit
    @user = User.find params[:id]
    @photo = @user.pictures.build
  end

  def update
    @user = User.find params[:id]
    @user.update_attributes(params[:user])
    respond_with(@user)
  end
end
