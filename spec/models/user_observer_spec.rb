require 'spec_helper'

describe UserObserver do

  describe 'after_update' do
    let(:user) { create :pixi_user }

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
  end

  describe 'after_create' do
    let(:user) { FactoryGirl.create :contact_user }

    it 'set default user_type' do
      user.user_type_code.should == 'mbr'
    end

    it 'set url' do
      expect(user.url).not_to be_nil
    end
  end
end
