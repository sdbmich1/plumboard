require 'spec_helper'

describe InquiryObserver do
  let(:user) { FactoryGirl.create(:contact_user) }

  describe 'after_create' do
    before { create(:inquiry_type) }
    it 'should deliver inquiry for signed in user' do
      @model = user.inquiries.build FactoryGirl.attributes_for(:inquiry, status: 'active')
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_inquiry).with(@model)
      @model.save!
    end

    it 'should deliver inquiry for non-signed in user' do
      @model = FactoryGirl.build :inquiry
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_inquiry).with(@model)
      @model.save!
    end

    it 'should deliver inquiry to pxb support' do
      @model = user.inquiries.build FactoryGirl.attributes_for(:inquiry, status: 'active')
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_inquiry_notice).with(@model)
      @model.save!
    end
  end
end
