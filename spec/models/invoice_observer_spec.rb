require 'spec_helper'

describe InvoiceObserver do
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:buyer) { FactoryGirl.create(:pixi_user, first_name: 'Bob', last_name: 'Davis', email: 'bob.davis@pixitest.com') }
  let(:listing) { FactoryGirl.create(:listing, seller_id: user.id) }

  def process_post
    @post = mock(Post)
    @observer = InvoiceObserver.instance
    @observer.stub(:send_post).with(@model).and_return(@post)
  end

  describe 'after_update' do

    before(:each) do
      @model = user.invoices.create FactoryGirl.attributes_for(:invoice, pixi_id: listing.pixi_id, buyer_id: buyer.id) 
      @model.price = 150.00
    end

    it 'should send a post' do
      process_post
    end
  end

  describe 'after_create' do

    before do
      @model = user.invoices.build FactoryGirl.attributes_for(:invoice, pixi_id: listing.pixi_id, buyer_id: buyer.id) 
    end

    it 'should send a post' do
      process_post
    end

    it 'should add inv pixi points' do
      @model.save!
      user.user_pixi_points.find_by_code('inv').code.should == 'inv'
    end
  end
end
