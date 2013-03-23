require 'spec_helper'

describe TempListingObserver do
  
  describe 'before_update' do

    describe 'reset status' do
      let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction }
      let(:user) { FactoryGirl.create :user }

      before(:each) do
        temp_listing.status = 'pending'
        temp_listing.save!
        temp_listing.approve_order user
        Listing.stub(:find_by_pixi_id).with(temp_listing.pixi_id).and_return(true)
      end

      it 'should reset status' do
        temp_listing.title = 'cute room for rent'
        temp_listing.save!
        temp_listing.status.should == 'edit'
      end
    end

    describe 'does not reset status' do
      let(:temp_listing) { FactoryGirl.create :temp_listing, status: 'new' }

      before(:each) do
        Listing.stub(:find_by_pixi_id).with(temp_listing.pixi_id).and_return(false)
      end

      it 'should not reset status' do
        temp_listing.title = 'cute room for rent'
        temp_listing.save!
        temp_listing.status.should_not == 'edit'
      end
    end
  end

  describe 'after_update' do
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction }

    before(:each) do
      temp_listing.status = 'approved'
      temp_listing.transaction.amt = 0.0
    end

    it 'should add listing and transaction' do
      temp_listing.save!
      Listing.stub(:create).with(temp_listing.attributes).and_return(true)
      temp_listing.stub!(:transaction).and_return(true)
    end

    it "should add listing" do
      expect {
	       temp_listing.save!
	     }.to change {Listing.count}.by(1)
    end

    it "should update transaction" do
      temp_listing.save!
      temp_listing.transaction.status.should == 'approved'
    end

    it "should not add listing" do
      temp_listing.status = 'pending'
      expect {
	       temp_listing.save!
	      }.to change {Listing.count}.by(0)
    end

    it 'should not add listing and transaction' do
      temp_listing.status = 'pending'
      temp_listing.save!
      temp_listing.transaction.status.should_not == 'approved'
    end
  end
end
