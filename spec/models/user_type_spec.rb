require 'spec_helper'

describe UserType do
  before(:each) do
    @user_type = build(:user_type)
  end

  subject { @user_type }

  it { should respond_to(:description) }
  it { should respond_to(:status) }
  it { should respond_to(:code) }
  it { should respond_to(:hide) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:code) }
  it { should have_many(:users).with_foreign_key('user_type_code') }

  describe "active user_types" do
    before { create(:user_type) }
    it { UserType.active.should_not be_nil } 
  end

  describe "inactive user_types" do
    before { create(:user_type, status: 'inactive') }
    it { UserType.active.should be_empty } 
  end

  describe "hidden user_types" do
    before { create(:user_type, code: 'active', hide: 'yes') }
    it { UserType.unhidden.should be_empty } 
  end

  describe "unhidden user_types" do
    before { create(:user_type, code: 'active', hide: 'no') }
    it { UserType.unhidden.should_not be_nil } 
  end
end
