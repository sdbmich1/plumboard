require 'spec_helper'

describe Subscription do
  before do
    @plan = create :plan
    @user = create :pixi_user
    @card_account = @user.card_accounts.create(FactoryGirl.attributes_for :card_account)
    @sub = @user.subscriptions.create(plan_id: @plan.id, card_account_id: @card_account.id)
  end

  subject { @sub }
  describe 'attributes' do
    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:plan_id) }
    it { is_expected.to respond_to(:stripe_id) }
    it { is_expected.to respond_to(:card_account_id) }
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:card_account) }
  end

  describe 'add_subscription' do
    def stub_stripe
      customer, sub = double(Stripe::Customer), double(Stripe::Subscription)
      allow(StripePayment).to receive(:get_customer).and_return(customer)
      allow(customer).to receive_message_chain(:subscriptions, create: sub)
      allow(sub).to receive(:id).and_return(1)
    end

    it 'creates subscription' do
      stub_stripe
      expect {
        Subscription.add_subscription(@plan.id, @user.id, @card_account.id)
      }.to change { Subscription.count }.by(1)
    end
  end

  describe 'cancel_subscription' do
    def stub_stripe
      stripe_sub = double(Stripe::Subscription)
      allow(StripePayment).to receive(:get_subscription).and_return(stripe_sub)
      allow(stripe_sub).to receive(:delete).and_return(true)
    end

    it 'sets status to "cancelled"' do
      stub_stripe
      expect(@sub.cancel_subscription).to be true
      expect(@sub.reload.status).to eq 'cancelled'
    end

    it 'does not set status to "cancelled" on Stripe error' do
      allow(StripePayment).to receive(:get_subscription).and_raise('error')
      expect(@sub.cancel_subscription).to be false
      expect(@sub.reload.status).not_to eq 'cancelled'
    end
  end

  describe 'update_subscription' do
    before do
      @new_plan = create :plan, name: 'Basic', price: 19.95, interval: 'month', trial_days: 0
    end

    def stub_stripe
      customer, sub = double(Stripe::Customer), double(Stripe::Subscription)
      allow(StripePayment).to receive(:get_customer).and_return(customer)
      allow(StripePayment).to receive(:get_subscription).and_return(sub)
      allow(sub).to receive_messages(:plan= => @new_plan.stripe_id)
      allow(sub).to receive(:save).and_return(true)
    end

    it 'updates plan' do
      stub_stripe
      expect(@sub.update_subscription(@new_plan)).to be true
      expect(@sub.reload.plan_id).to eq @new_plan.id
    end

    it 'does not update plan on Stripe error' do
      allow(StripePayment).to receive(:get_subscription).and_raise('error')
      expect(@sub.update_subscription(@new_plan)).to be false
      expect(@sub.reload.plan_id).not_to eq @new_plan.id
    end
  end

  describe 'process_error' do
    it 'adds error' do
      expect {
        @sub.process_error(Exception.new)
      }.to change { @sub.errors.count }.by(1)
    end
  end
end
