require 'spec_helper'

describe UserObserver do

  describe 'after_update' do
    let(:user) { create :contact_user }

    it 'should add act pixi points' do
      user.first_name = 'Sam'
      user.save!
      user.user_pixi_points.last.code.should == 'act'
    end

    it 'should add lb pixi points' do
      user.last_sign_in_at = Time.now
      user.save!
      user.user_pixi_points.last.code.should == 'lb'
    end

    it 'updates the role' do
      role = 'pixter'
      user.user_type_code = 'PT'
      user.save!
      expect(user.roles.find_by_name(role.to_s.camelize).blank?).to eq(false)
    end

    it 'does not update the role' do
      role = 'member'
      user.user_type_code = 'MBR'
      user.save!
      expect(user.roles.find_by_name(role.to_s.camelize).blank?).to eq(true)
    end

    it 'other fields do not update the role' do
      role = 'member'
      user.last_name = 'Miles'
      user.save!
      expect(user.roles.find_by_name(role.to_s.camelize).blank?).to eq(true)
    end

    context 'payment' do
      before :each, run: true do
        acct = user.bank_accounts.create FactoryGirl.attributes_for :bank_account
      end

      it 'should not call update account' do
        user.birth_date = '01/03/1989'.to_date
        user.save!
        StripePayment.stub(:update_account).and_return(StripePayment)
        StripePayment.should_not_receive(:update_account).with(user)
      end

      it 'should call update account', run: true do
        user.birth_date = '01/03/1989'.to_date
        user.save!
        StripePayment.should_receive(:update_account)
	StripePayment.update_account(user, user.acct_token, '127.0.0.1')
      end

      it 'should not call update account' do
        user.first_name = 'Jack'
        StripePayment.should_not_receive(:update_account).with(user)
        user.save!
      end
    end
  end
end
