require 'spec_helper'

describe InquiryObserver do
  let(:user) { FactoryGirl.create(:contact_user) }

  describe 'after_create' do
    before { create(:inquiry_type) }
    it 'should deliver inquiry for signed in user' do
      @model = user.inquiries.build FactoryGirl.attributes_for(:inquiry, status: 'active')
      @user_mailer = double(UserMailer)
      expect(UserMailer).to receive(:send_inquiry).with(@model).and_return(@user_mailer)
      expect(@user_mailer).to receive(:deliver_later)
      @model.save!
    end

    it 'should deliver inquiry for non-signed in user' do
      @model = FactoryGirl.build :inquiry
      @user_mailer = double(UserMailer)
      expect(UserMailer).to receive(:send_inquiry).with(@model).and_return(@user_mailer)
      expect(@user_mailer).to receive(:deliver_later)
      @model.save!
    end

    it 'should deliver inquiry to pxb support' do
      @model = user.inquiries.build FactoryGirl.attributes_for(:inquiry, status: 'active')
      @user_mailer = double(UserMailer)
      expect(UserMailer).to receive(:send_inquiry).with(@model).and_return(@user_mailer)
      expect(@user_mailer).to receive(:deliver_later)
      @model.save!
    end
  end
end
