require 'spec_helper'

describe "Devices API" do
  before do
    @user = create :pixi_user
  end

  let(:params) { { format: :json, id: 'abc', user_id: @user.id } }

  it 'valid device params' do
    post '/api/v1/devices.json', params
    expect(response).to be_success
    expect(json['device']).not_to be_nil
  end

  it 'invalid device params' do
    params[:id] = nil
    post '/api/v1/devices.json', params
    expect(response).not_to be_success
    expect(json['message']).not_to be_nil
  end
end
