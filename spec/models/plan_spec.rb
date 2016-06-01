require 'spec_helper'

describe Plan do
  before do
    @plan = create :plan
  end

  subject { @plan }
  describe 'attributes' do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:interval) }
    it { is_expected.to respond_to(:price) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:stripe_id) }
    it { is_expected.to respond_to(:trial_days) }
    it { is_expected.to have_many(:subscriptions) }
  end

  describe 'add_plan' do
    it 'creates plan' do
      expect {
        Plan.add_plan('Pro', 69.95, 'month', 0)
      }.to change { Plan.count }.by(1)
    end
  end

  describe 'remove_plan' do
    def stub_stripe
      stripe_plan = double(Stripe::Plan)
      allow(StripePayment).to receive(:get_plan).and_return(stripe_plan)
      allow(stripe_plan).to receive(:delete).and_return(true)
    end

    it 'sets status to "removed"' do
      stub_stripe
      expect(@plan.remove_plan).to be true
      expect(@plan.reload.status).to eq 'removed'
    end

    it 'does not status to "removed" on Stripe error' do
      allow(StripePayment).to receive(:get_plan).and_raise('error')
      expect(@plan.remove_plan).to be false
      expect(@plan.reload.status).not_to eq 'removed'
    end
  end

  describe 'update_plan' do
    def stub_stripe
      stripe_plan = double(Stripe::Plan)
      allow(StripePayment).to receive(:get_plan).and_return(stripe_plan)
      messages = { :name= => 'Basic', :price= => 19.95, :interval= => 'month', :trial_period_days= => 0 }
      allow(stripe_plan).to receive_messages(messages)
      allow(stripe_plan).to receive(:save).and_return(true)
    end

    it 'updates attributes' do
      stub_stripe
      old_name = @plan.name
      expect(@plan.update_plan('Basic')).to be true
      expect(Plan.where(name: old_name).exists?).to be false
      expect(Plan.where(name: 'Basic').exists?).to be true
    end

    it 'does not update attributes on Stripe error' do
      allow(StripePayment).to receive(:get_plan).and_raise('error')
      expect(@plan.update_plan('Basic')).to be false
    end
  end

  describe 'process_error' do
    it 'adds error' do
      expect {
        @plan.process_error(Exception.new)
      }.to change { @plan.errors.count }.by(1)
    end
  end
end
