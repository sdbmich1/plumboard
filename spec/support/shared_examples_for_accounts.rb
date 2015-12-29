require 'spec_helper'

shared_examples "account list methods" do |factory, klass, method|
  describe 'check list' do
    before :each do
      @account = create factory.to_sym, user_id: @user.id
    end

    context 'admins' do
      before :each do
        @other = create(:contact_user)
	@acct = create factory.to_sym, user_id: @other.id
        @user.update_attribute(:user_type_code, "AD")
      end

      it 'shows card holder list' do
        expect(klass.constantize.send(method, @user, true).size).to be > 1
      end

      it 'shows card list' do
        expect(klass.constantize.send(method, @user, false).size).to be > 1
      end

      it 'does not show card holder list' do
        expect(klass.constantize.send(method, @other, true).size).to eq 1
      end
    end

    context 'non-admins' do
      it 'does not show card holder list' do
        expect(klass.constantize.send(method, @user, true).size).to eq 1
      end

      it 'shows card list' do
        expect(klass.constantize.send(method, @user, false).size).to eq 1
      end
    end
  end
end
