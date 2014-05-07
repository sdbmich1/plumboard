require 'spec_helper'

describe PostObserver do
  describe 'after_create' do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:recipient) { FactoryGirl.create :pixi_user, first_name: 'Julia', last_name: 'Child', email: 'jchild@pixitest.com' }
    let(:listing) { FactoryGirl.create :listing, seller_id: user.id }
    let(:post) { listing.posts.build(content: "Lorem ipsum", user_id: user.id, recipient_id: recipient.id) }

    it 'delivers user notice' do
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_notice).with(post)
      post.save!
    end

    it 'does not deliver 2nd notice' do
      post.msg_type = 'approve'
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_not_receive(:send_notice).with(post)
      post.save!
    end

    it 'deny msg does not deliver 2nd notice' do
      post.msg_type = 'deny'
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_not_receive(:send_notice).with(post)
      post.save!
      post.reload.content.should_not match(/explanation/)
    end

    it 'wanted msg does not deliver 2nd notice' do
      post.msg_type = 'want'
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_not_receive(:send_notice).with(post)
      post.save!
    end

    it 'should add pixi points' do
      post.save!
      user.user_pixi_points.find_by_code('cs').code.should == 'cs'
    end
  end
end
