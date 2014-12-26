require 'spec_helper'
require 'rake'

describe EventType do
    before(:each) do
        @event_type = build(:event_type)
    end
    
    subject { @event_type }
    
    it { should respond_to(:description) }
    it { should respond_to(:status) }
    it { should respond_to(:code) }
    it { should respond_to(:hide) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:hide) }
    
    it { should have_many(:listings).with_foreign_key('event_type_code') }
    it { should have_many(:temp_listings).with_foreign_key('event_type_code') }

     describe '.event_type' do
        before do
            @etype = FactoryGirl.create(:event_type, code: 'party')
            @listing1 = FactoryGirl.create(:listing)
            @listing1.category_id = 'event'
            @listing1.event_type_code = 'party'
        end
        
        it "should be an event" do
            !(@listing1.event?.nil?)
        end
        
        it "should respond to .event_type" do
            @listing1.event_type == 'party'
        end
            
        it "etype should respond to listings.first" do
            !(@etype.listings.first.nil?)
        end
    end

    
    describe "active event_types" do
        before { create(:event_type) }
        it { EventType.active.should_not be_nil }
    end
    
    describe "inactive event_types" do
        before { create(:event_type, status: 'inactive') }
        it { EventType.active.should be_empty }
    end

  describe 'nice_descr' do
    it { @event_type.nice_descr.should == @event_type.description.titleize }

    it 'does not return titleized description' do
      @event_type.description = nil
      @event_type.nice_descr.should be_nil
    end
  end

end
