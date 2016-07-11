require 'spec_helper'

describe Device do
  before do
    @user = create :pixi_user
    @device = @user.devices.create
  end

  subject { @device }
  describe 'attributes', base: true do
    describe '#attributes' do
      subject { super().attributes }
      it { is_expected.to include(*%w(user_id token platform status vibrate)) }
    end
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_presence_of(:token) }
    it { is_expected.to validate_presence_of(:token) }
    it { is_expected.to validate_uniqueness_of(:token).scoped_to(:user_id) }
  end
end
