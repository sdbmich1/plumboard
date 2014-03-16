require 'spec_helper'

describe PixiPostObserver do
  let(:user) { FactoryGirl.create(:contact_user) }

  def update_addr
    @user = mock(User)
    @observer = PixiPostObserver.instance
    @observer.stub(:update_contact_info).with(@model).and_return(@user)
  end

  describe 'after_create' do
    it 'should add pixi points' do
      @model = user.pixi_posts.build FactoryGirl.attributes_for(:pixi_post, status: 'active', address: '3456 Elm')
      @pixi_point = FactoryGirl.create :pixi_point, code: 'ppx', value: 100, action_name: 'Add PixiPost Request', category_name: 'Post'
      @model.save!
      user.user_pixi_points.find_by_code('ppx').code.should == 'ppx'
    end

    it 'should deliver request notice' do
      @model = user.pixi_posts.build FactoryGirl.attributes_for(:pixi_post, status: 'active')
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_pixipost_request).with(@model)
      @model.save!
    end

    it 'updates contact info' do
      @model = user.pixi_posts.build FactoryGirl.attributes_for(:pixi_post, status: 'active')
      @model.save!
      update_addr
      @model.user.contacts[0].address.should == @model.address 
    end

    it 'should deliver appt notice' do
      @pixan = FactoryGirl.create :pixi_user
      @model = user.pixi_posts.build FactoryGirl.attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Date.today+2.days
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_pixipost_appt).with(@model)
      @model.save!
    end
  end
end
