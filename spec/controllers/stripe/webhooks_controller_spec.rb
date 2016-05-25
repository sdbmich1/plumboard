require 'spec_helper'

describe Stripe::WebhooksController do
  def do_post
    post :create, id: 1
  end

  describe 'POST create' do
    it 'succeeds' do
      allow(Stripe::Event).to receive(:retrieve)
      allow(WebhookFacade).to receive_message_chain(:new, :process)
      do_post
      expect(response.status).to eq 201
    end

    it 'fails' do
      do_post
      expect(response.status).to eq 400
    end
  end
end
