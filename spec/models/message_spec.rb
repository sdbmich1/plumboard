require 'spec_helper'

describe Message do
  before :each do
    @msg = create :message
  end

  subject { @msg }
  describe 'attributes', base: true do
    describe '#attributes' do
      subject { super().attributes }
      it { is_expected.to include(*%w(user_id device_id message_type_code
        content priority reg_id collapse_key)) }
    end
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:device) }
    it { is_expected.to belong_to(:message_type) }
  end

  describe 'add_message' do
    it 'adds to redis list' do
      expect {
        @msg.add_message({message_type: 'favorite'})
      }.to change { $redis.llen('favorite') }.by(1)
    end
  end

  describe 'send_message' do
    it 'adds to redis list' do
      @msg.add_message({message_type: 'favorite'})
      expect {
        Message.send_message('favorite')
      }.to change { $redis.llen('favorite') }.by(-1)
    end
  end
end
