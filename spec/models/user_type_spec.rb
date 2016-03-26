require 'spec_helper'

describe UserType do
  before(:each) do
    @user_type = build(:user_type)
  end

  subject { @user_type }

  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:hide) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to have_many(:users).with_foreign_key('user_type_code') }

  describe "active user_types" do
    before { create(:user_type) }
    it { expect(UserType.active).not_to be_nil } 
  end

  describe "inactive user_types" do
    before { create(:user_type, status: 'inactive') }
    it { expect(UserType.active).to be_empty } 
  end

  describe "hidden user_types" do
    before { create(:user_type, code: 'active', hide: 'yes') }
    it { expect(UserType.unhidden).to be_empty } 
  end

  describe "unhidden user_types" do
    before { create(:user_type, code: 'active', hide: 'no') }
    it { expect(UserType.unhidden).not_to be_nil } 
  end
end
