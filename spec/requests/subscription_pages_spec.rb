require 'spec_helper'

feature 'Subscriptions' do
  subject { page }
  
  let(:user) { create :business_user }
  let(:plan) { create :plan }
  let(:state) { create :state, state_name: 'California', code: 'CA' }
  let(:card_account) { user.card_accounts.create(FactoryGirl.attributes_for :card_account) }
  let(:subscription) { create :subscription, user_id: user.id, plan_id: plan.id, card_account_id: card_account.id }

  def test_index
    expect(page).to have_content 'User Plan Card Start Date'
    expect(page).to have_content user.name
    expect(page).to have_content subscription.plan_name
    expect(page).to have_content card_account.card_no
    expect(page).to have_content ResetDate.display_date_by_loc(subscription.created_at, nil, true)
    expect(page).to have_link 'Details', href: subscription_path(subscription.id)
    expect(page).not_to have_content 'No subscriptions found'
  end

  def stub_stripe method='get', method2='delete'
    stripe_sub = double(Stripe::Subscription, id: '123')
    allow(StripePayment).to receive("#{method}_subscription".to_sym).and_return(stripe_sub)
    allow(stripe_sub).to receive(method2.to_sym).and_return(true)
  end

  describe 'index' do
    context 'without subscription data' do
      before :each do
        init_setup user
        visit subscriptions_path
      end

      it 'should display navbar' do
        expect(page).to have_link('Bank')
        expect(page).to have_link('Card')
        expect(page).to have_link('Subscription')
      end

      it 'should display "Add Subscription" button' do
        expect(page).to have_link('Add Subscription', href: new_subscription_path)
      end

      it 'should display "No subscriptions found" when there are no subscriptions' do
        expect(page).to have_content 'No subscriptions found'
        expect(page).not_to have_content 'User Plan Card Start Date'
      end
    end

    context 'with subscription data' do
      it 'should display subscription data when there are subscriptions' do
        subscription
        init_setup user
        visit subscriptions_path
        test_index
      end

      it "should not display other users' subscriptions" do
        other_user = create :contact_user
        subscription
        init_setup other_user
        visit subscriptions_path
        expect(page).to have_content 'No subscriptions found'
        expect(page).not_to have_content 'User Plan Card Start Date'
      end
    end
  end

  describe 'index (admin)' do
    before :each do
      admin = create :admin
      init_setup admin
    end

    it "should display other users' subscriptions" do
      subscription
      visit subscriptions_path(adminFlg: true)
      test_index
    end
  end

  describe 'new' do
    before do
      plan
      card_account
      state
      user.contacts.first.update_attribute(:state, 'CA')
      init_setup user
      stub_stripe 'add', 'create'
      visit new_subscription_path
    end

    it 'has form fields' do
      expect(page).to have_content('Subscriber Name')
      expect(page).to have_content('Plan Type')
      expect(page).to have_content('Billing Address')
      expect(page).to have_content('Payment Information')
      expect(page).to have_link('Change', count: 2)
    end

    it 'displays contact info' do
      contact = user.contacts.first
      expect(page).to have_content(contact.address)
      expect(page).to have_content(contact.city)
      expect(page).to have_content(contact.state)
      expect(page).to have_content(contact.zip)
      expect(page).to have_content(contact.country)
    end

    it 'displays credit card info' do
      expect(page).to have_content(card_account.card_type)
      expect(page).to have_content(card_account.card_no)
      expect(page).to have_content(card_account.expiration_month)
      expect(page).to have_content(card_account.expiration_year)
    end

    it 'loads default values', js: true do
      expect { click_button('Done!') }.to change { Subscription.count }
    end

    it 'selects user', js: true do
      other_user = create :business_user, business_name: 'Test Business'
      fill_autocomplete 'slr_name', with: other_user.business_name
      click_button('Done!')
      expect(Subscription.exists?(user_id: other_user.id)).to be true
    end

    it 'selects plan', js: true do
      plan2 = create :plan, name: 'Test'
      visit new_subscription_path
      select(plan2.name, from: 'subscription_plan_id')
      click_button('Done!')
      expect(Subscription.exists?(plan_id: plan2.id)).to be true
    end

    it 'edits contact data and creates new contact', js: true do
      create :state, state_name: 'Minnesota', code: 'MN'
      attrs = {
        home_phone: 8009253368,
        address: '155 Fifth Ave S',
        city: 'Minneapolis',
        state: 'MN',
        zip: 55401,
        contactable_type: 'Subscription'
      }
      visit new_subscription_path
      click_on('edit-txn-addr')
      fill_in('subscription_contact_attributes_home_phone', with: attrs[:home_phone])
      fill_in('subscription_contact_attributes_address', with: attrs[:address])
      fill_in('subscription_contact_attributes_city', with: attrs[:city])
      select('Minnesota', from: 'subscription_contact_attributes_state')
      fill_in('postal_code', with: attrs[:zip])
      click_button('Done!')
      sleep 2
      expect(Contact.exists?(attrs)).to be true
    end

    it 'cancel button goes back', js: true do
      visit subscriptions_path
      visit new_subscription_path
      click_link('Cancel')
      click_button('OK')
      expect(page).not_to have_content('Your Subscription')
      expect(page).to have_content('Add Subscription')
    end
  end

  describe 'show' do
    before :each do
      init_setup user
    end

    it 'displays "Subscription not found." when there is no subscription' do
      visit subscription_path(subscription.id + 1)
      expect(page).to have_content('Subscription not found.')
      expect(page).not_to have_content('Your Subscription')
    end

    it 'displays subscription data' do
      visit subscription_path(subscription)
      expect(page).to have_content('Your Subscription')
      expect(page).to have_content('Business Name:')
      expect(page).to have_content(subscription.user.business_name)
      expect(page).to have_content('Plan Name:')
      expect(page).to have_content(subscription.plan_name)
      expect(page).to have_content('Start Date:')
      expect(page).to have_content(ResetDate.display_date_by_loc(subscription.created_at, nil, true))
      expect(page).to have_content('Card #:')
      expect(page).to have_content(subscription.card_account.card_no)
      expect(page).not_to have_content('Subscription not found.')
    end

    it '"Remove" button should delete subscription', js: true do
      stub_stripe
      subscription
      visit subscription_path(subscription)
      expect {
        click_link('Remove')
        click_button('OK')
        sleep 2
      }.to change { Subscription.where(status: 'cancelled').count }.by(1)
    end

    it '"Edit" button should edit a subscription', js: true do
      subscription.create_contact(FactoryGirl.attributes_for :contact)
      plan2 = create :plan, name: 'Test'
      allow(Payment).to receive(:update_subscription).and_return(true)
      visit subscription_path(subscription)
      click_link('Edit')
      # Should be no 'Change' button for credit card info
      expect(page).to have_link('Change', count: 1)
      select(plan2.name, from: 'subscription_plan_id')
      click_button('Done!')
      expect(page).to have_content(plan2.name)
      expect(page).not_to have_content(plan.name)
    end
  end
end
