class Api::V1::DevicesController < ApplicationController
  respond_to :json

  def create
    unless request.format == :json
      render json: { message: 'The request must be json' }, status: 406
      return
    end

    @device = Device.find_or_initialize_by(token: params[:id], user_id: params[:user_id])

    if @device.save
      render json: { device: @device }, status: 200
    else
      render json: { message: "#{@device.errors.messages}." }, status: 401
    end
  end
end

