require 'spec_helper'

describe TempListingObserver do

  def send_mailer msg
    @mailer = mock(UserMailer)
    @observer = TempListingObserver.instance
    @observer.stub(:delay).with(@mailer).and_return(@mailer)
    if msg == 'send_denial'
      @observer.stub(:send_denial).with(@model).and_return(@mailer)
    else
      @observer.stub(:send_submit_notice).with(@model).and_return(@mailer)
    end
  end

  def send_message 
    @post = mock(Post)
    @observer = TempListingObserver.instance
    @observer.stub(:send_system_message).with(@model).and_return(true)
  end

  describe 'after_update' do

    before(:each) do
      @user = create :contact_user 
      @temp_listing = create :temp_listing_with_transaction, seller_id: @user.id
      @temp_listing.status = 'approved'
      @temp_listing.transaction.amt = 0.0
    end

    it 'adds listing and transaction' do
      @temp_listing.save!
      Listing.stub(:create).with(@temp_listing.attributes).and_return(true)
      @temp_listing.stub!(:transaction).and_return(true)
    end

    it "approves listing" do
      expect {
	    @temp_listing.save!
      }.to change {Listing.count}.by(1)
      @temp_listing.transaction.status.should == 'approved'
      @temp_listing.transaction.status.should_not == 'pending'
    end

    it "submits listing" do
      @temp_listing.status = 'pending'
      expect {
	    @temp_listing.save!
      }.to change {Listing.count}.by(0)
      @temp_listing.transaction.status.should_not == 'approved'
      @temp_listing.transaction.status.should == 'pending'
      send_mailer 'send_submit_notice'
    end

    it 'delivers denial message' do
      @temp_listing.status = 'denied'
      @temp_listing.save!
      send_mailer 'send_denial'
    end

    it 'delivers denial system message' do
      create :admin, email: PIXI_EMAIL
      @temp_listing.status = 'denied'
      @temp_listing.save!
      send_message 
      expect(Post.all.count).to eq(1)
    end
  end
end
