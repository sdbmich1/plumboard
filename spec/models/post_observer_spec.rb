require 'spec_helper'

describe PostObserver do
  describe 'after_create' do
    let(:user) { create :pixi_user }
    let(:recipient) { create :pixi_user, first_name: 'Julia', last_name: 'Child', email: 'jchild@pixitest.com' }
    let(:listing) { create :listing, seller_id: user.id }
    let(:conversation) {listing.conversations.create FactoryGirl.attributes_for :conversation, user_id: user.id, recipient_id: recipient.id}
    let(:post) { conversation.posts.build FactoryGirl.attributes_for :post, user_id: user.id, recipient_id: recipient.id, pixi_id: listing.pixi_id }

    def process_msg model, mtype
      @user_mailer = double(UserMailer)

      if mtype.blank?
        expect(UserMailer).to receive(:send_notice).with(model).and_return(@user_mailer)
        expect(@user_mailer).to receive(:deliver_later)
      else
        model.msg_type = mtype
        expect(UserMailer).not_to receive(:send_notice).with(post)
      end
      model.save!
    end

    it 'delivers user notice' do
      process_msg post, ''
    end

    it 'does not deliver 2nd notice' do
      process_msg post, 'approve'
    end

    it 'deny msg does not deliver 2nd notice' do
      process_msg post, 'deny'
      expect(post.reload.content).not_to match(/explanation/)
    end

    it 'wanted msg does not deliver 2nd notice' do
      process_msg post, 'want'
    end

    it 'asked msg does not deliver 2nd notice' do
      process_msg post, 'ask'
    end

    it 'repost msg does not deliver 2nd notice' do
      process_msg post, 'repost'
    end

    it 'invoice msg does not deliver 2nd notice' do
      process_msg post, 'inv'
    end

    it 'should add pixi points' do
      post.save!
      expect(user.user_pixi_points.find_by_code('cs').code).to eq('cs')
    end
  end
end
