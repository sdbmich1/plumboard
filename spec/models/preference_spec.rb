require 'spec_helper'

describe Preference do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @preference = @user.preferences.build FactoryGirl.attributes_for(:preference) 
  end

  subject { @preference }

  it { should respond_to(:user_id) }
  it { should respond_to(:zip) }
  it { should respond_to(:email_msg_flg) }
  it { should respond_to(:mobile_msg_flg) }
  it { should belong_to(:user) }
  it { should ensure_length_of(:zip).is_equal_to(5) }
  it { should allow_value(41572).for(:zip) }
  it { should_not allow_value(725).for(:zip) }
  it { should_not allow_value('a725').for(:zip) }
end
