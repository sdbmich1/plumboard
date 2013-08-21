require 'spec_helper'

describe UserObserver do

  def send_mailer usr
    @mailer = mock(UserMailer)
    @observer = InvoiceObserver.instance
    @observer.stub(:delay).with(@mailer).and_return(@mailer)
    @observer.stub(:welcome_email).with(usr).and_return(@mailer)
  end

  describe 'after_update' do
    let(:user) { FactoryGirl.create :pixi_user }

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
  end

  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:pixi_user) { FactoryGirl.create :pixi_user, uid: '11111' }

    it 'adds dr pixi points' do
      user.user_pixi_points.find_by_code('dr').code.should == 'dr'
    end

    it 'adds fr pixi points' do
      pixi_user.user_pixi_points.find_by_code('fr').code.should == 'fr'
    end

    it 'delivers the welcome message' do
      send_mailer user
    end
  end
end
