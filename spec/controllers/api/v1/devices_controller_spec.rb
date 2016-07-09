require 'spec_helper'

describe Api::V1::DevicesController do
  describe 'POST create' do
    def do_post(save_val)
      device = stub_model(Device)
      allow(Device).to receive(:find_or_initialize_by).and_return(device)
      allow(device).to receive(:save).and_return(save_val)
      post :create, id: 1, user_id: 2, format: :json
    end

    context 'success' do
      it 'returns 200 status' do
        do_post(true)
        expect(response.status).to eq 200
      end

      it 'returns device' do
        do_post(true)
        expect(response.body['device']).not_to be_nil
      end
    end

    context 'failure' do
      it 'returns 401 status' do
        do_post(false)
        expect(response.status).to eq 401
      end

      it 'returns error message' do
        do_post(false)
        expect(response.body['message']).not_to be_nil
      end

      it 'non-json request returns 406 status' do
        post :create
        expect(response.status).to eq 406
      end

      it 'non-json request returns error message' do
        post :create
        expect(response.body['message']).not_to be_nil
      end
    end
  end
end
