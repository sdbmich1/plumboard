require 'spec_helper'

describe MessageType do
  before :each do
    @message_type = create :message_type
  end

  subject { @message_type }
  describe 'attributes', base: true do
    describe '#attributes' do
      subject { super().attributes }
      it { is_expected.to include(*%w(code description recipient status)) }
    end
    it { is_expected.to have_many(:messages) }
  end

  describe 'get_codes' do
    it 'returns active' do
      @message_type.update_attribute(:status, 'active')
      expect(MessageType.get_codes).to include @message_type
    end

    it 'does not return non-active' do
      @message_type.update_attribute(:status, 'inactive')
      expect(MessageType.get_codes).not_to include @message_type
    end
  end
end
