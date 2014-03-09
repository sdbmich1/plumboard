require 'spec_helper'

describe ListingObserver do
  let(:user) { FactoryGirl.create :pixi_user }

  def delete_pixi model
    @listing = mock(TempListing)
    @observer = ListingObserver.instance
    @observer.stub(:delete_temp_pixi).with(@model).and_return(true)
  end

  def send_mailer
    @mailer = mock(UserMailer)
    @observer = ListingObserver.instance
    @observer.stub(:delay).with(@mailer).and_return(@mailer)
    @observer.stub(:send_approval).with(@model).and_return(@mailer)
  end

  def send_message 
    @post = mock(Post)
    @observer = ListingObserver.instance
    @observer.stub(:send_system_message).with(@model).and_return(true)
  end

  describe 'after_create' do
    let(:category) { FactoryGirl.create :category }

    it 'adds abp pixi points' do
      listing = FactoryGirl.create(:listing, seller_id: user.id)
      user.user_pixi_points.find_by_code('abp').code.should == 'abp'
    end

    it 'adds app pixi points' do
      @category = FactoryGirl.create(:category, pixi_type: 'premium')
      listing = FactoryGirl.create(:listing, category_id: @category.id, seller_id: user.id)
      user.user_pixi_points.find_by_code('app').code.should == 'app'
    end

    it 'deletes temp pixi' do
      listing = FactoryGirl.create(:listing, seller_id: user.id)
      delete_pixi listing
    end

    it 'delivers system message' do
      create :admin, email: PIXI_EMAIL
      listing = create(:listing, seller_id: user.id)
      send_message 
      expect(Post.all.count).to eq(1)
    end

    it 'delivers approval email' do
      send_mailer
    end
  end

  describe 'after_update' do
    it 'deletes temp pixi' do
      listing = FactoryGirl.create(:listing, seller_id: user.id)
      delete_pixi listing
    end
  end
end
