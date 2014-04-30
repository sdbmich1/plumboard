require 'spec_helper'

describe UserObserver do

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

    it 'set default user_type' do
      user.user_type_code.should == 'mbr'
    end
  end
end
