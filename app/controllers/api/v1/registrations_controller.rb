class Api::V1::RegistrationsController < ApplicationController
  respond_to :json

  def create
    if request.format != :json
      render :status=>406, :json=>{:message=>"The request must be json"}
      return
    end

    if params[:file].blank?
      user = User.new(params[:user])
    else
      user = User.new(JSON.parse(params[:user]))
      pic = user.pictures.build
      pic.photo = File.new params[:file].tempfile 
    end

    if user.save
      render :status=>200, :json=>{:user=>user, :token=>user.authentication_token}
      return
    else
      render :status=>401, :json=>{:message=>"#{user.errors.messages}."}
    end
  end
end

