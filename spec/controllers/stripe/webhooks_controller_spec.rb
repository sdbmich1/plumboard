require 'spec_helper'

describe Stripe::WebhooksController do
  before do
    StripeMock.start
    @user = create :pixi_user
    @plan = create :plan
    @sub = @user.subscriptions.create(plan_id: @plan.id, stripe_id: 'sub_abcdefghijklmn')
  end

  def do_post
    post :create, id: 1
  end

  describe 'POST create' do
    def test_webhook(webhook, method, args)
      event = StripeMock.mock_webhook_event(webhook, email: @user.email, id: @sub.stripe_id)
      allow(Stripe::Event).to receive(:retrieve).and_return(event)
      user_mailer = double(UserMailer)
      expect(UserMailer).to receive(method).with(*args).and_return(user_mailer)
      expect(user_mailer).to receive(:deliver_later)
      do_post
      expect(response.status).to eq 201
    end

    it 'calls UserMailer method' do
      test_webhook('charge.failed', :send_charge_failed, [@user])
      test_webhook('charge.dispute.created', :send_charge_dispute_created, [@user])
      test_webhook('charge.dispute.updated', :send_charge_dispute_updated, [@user])
      test_webhook('charge.dispute.closed', :send_charge_dispute_closed, [@user])
      test_webhook('customer.subscription.created', :send_customer_subscription_created, [@user, @sub])
      test_webhook('customer.subscription.trial_will_end', :send_customer_subscription_trial_will_end, [@user, @sub])
      test_webhook('customer.subscription.updated', :send_customer_subscription_updated, [@user, @sub])
      test_webhook('customer.subscription.deleted', :send_customer_subscription_deleted, [@user, @sub])
      test_webhook('customer.updated', :send_customer_updated, [@user])
    end

    it 'returns 400 on Stripe Error' do
      allow(Stripe::Event).to receive(:retrieve)
      allow(WebhookFacade).to receive_message_chain(:new, :process).and_raise(Stripe::StripeError)
      do_post
      expect(response.status).to eq 400
    end
  end
end
