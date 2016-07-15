require 'spec_helper'

describe Subscription do
  before do
    @plan = create :plan
    @user = create :contact_user
    @card_account = @user.card_accounts.create(FactoryGirl.attributes_for :card_account)
    @contact = @user.contacts.first
    @sub = @user.subscriptions.create(
      plan_id: @plan.id,
      card_account_id: @card_account.id,
    )
    @contact.contactable_id = @sub.id
    @contact.contactable_type = 'Subscription'
    @contact.save
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
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:plan_id) }
    it { is_expected.to validate_presence_of(:card_account_id) }
    it { is_expected.to have_one(:contact) }
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
      sub = Subscription.new(plan_id: @plan.id, user_id: @user.id,
        card_account_id: @card_account.id)
      expect {
        sub.add_subscription
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
      allow(Stripe::Plan).to receive(:retrieve).and_return(@new_plan)
      allow(sub).to receive_messages(:plan= => @new_plan.stripe_id)
      allow(sub).to receive(:save).and_return(true)
    end

    it 'updates subscription' do
      stub_stripe
      other_user = create :contact_user
      params = {
        subscription: {
          plan_id: @new_plan.id,
          user_id: other_user.id,
          contact_attributes: { city: 'New York' }
        }
      }
      expect(@sub.update_subscription(params)).to be true
      expect(@sub.reload.plan_id).to eq @new_plan.id
      expect(@sub.user_id).to eq other_user.id
      expect(@sub.contact.city).to eq 'New York'
    end

    it 'does not update on Stripe error' do
      allow(StripePayment).to receive(:get_subscription).and_raise('error')
      expect(@sub.update_subscription(@new_plan)).to be false
      expect(@sub.reload.plan_id).not_to eq @new_plan.id
    end
  end

  describe 'plan_name' do
    it 'returns plan name' do
      expect(@sub.plan_name).to eq @plan.name
    end

    it 'returns nil if no plan name' do
      sub = Subscription.new
      expect(sub.plan_name).to be_nil
    end
  end

  describe 'plan_price' do
    it 'returns plan price' do
      expect(@sub.plan_price).to eq @plan.price
    end

    it 'returns 0.0 if no plan price' do
      sub = Subscription.new
      expect(sub.plan_price).to eq 0.0
    end
  end

  describe 'load_new' do
    it 'returns Subscription with plan_id and user_id assigned' do
      sub = Subscription.load_new(@plan.id, @user)
      expect(sub.plan_id).to eq @plan.id
      expect(sub.user_id).to eq @user.id
    end
  end

  describe 'load_data' do
    it 'assigns contact info if available' do
      @sub.load_data(@user)
      expect(@sub.contact.address).to eq @contact.address
      expect(@sub.contact.city).to eq @contact.city
      expect(@sub.contact.zip).to eq @contact.zip
      expect(@sub.contact.state).to eq @contact.state
      expect(@sub.contact.work_phone).to eq @contact.work_phone
      expect(@sub.contact.country).to eq @contact.country
    end
  end

  describe 'add_card_account' do
    it 'sets card_account_id if provided' do
      @sub.add_card_account({ subscription: { card_account_id: 2 } })
      expect(@sub.card_account_id).to eq 2
    end

    it 'creates card otherwise' do
      params = {
        subscription: {
          user_id: @user.id,
          plan_id: @plan.id,
          contact_attributes: { zip: 94720 },
          card_account_id: '',
          card_account_attributes: {
            card_number: '4242424242424242',
            cvv: '123'
          }
        },
        card_month: 12,
        card_year: 2017
      }
      expect_any_instance_of(CardAccount).to receive(:save_account)
      @sub.add_card_account(params)
    end
  end

  describe 'sub_list' do
    before :all do
      @other_user = create :contact_user
    end

    it 'returns all subscriptions if adminFlg is true' do
      expect(Subscription.sub_list(@other_user, true)).to include(@sub)
    end

    it 'only returns user subscriptions if adminFlg is false' do
      expect(Subscription.sub_list(@other_user, false)).not_to include(@sub)
      expect(Subscription.sub_list(@user, false)).to include(@sub)
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
