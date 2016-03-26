require 'spec_helper'
require 'rake'

describe EventType do
    before(:each) do
        @event_type = build(:event_type)
    end
    
    subject { @event_type }
    
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:code) }
    it { is_expected.to respond_to(:hide) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:hide) }
    
    it { is_expected.to have_many(:listings).with_foreign_key('event_type_code') }
    it { is_expected.to have_many(:temp_listings).with_foreign_key('event_type_code') }

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
        it { expect(EventType.active).not_to be_nil }
    end
    
    describe "inactive event_types" do
        before { create(:event_type, status: 'inactive') }
        it { expect(EventType.active).to be_empty }
    end

  describe 'nice_descr' do
    it { expect(@event_type.nice_descr).to eq(@event_type.description.titleize) }

    it 'does not return titleized description' do
      @event_type.description = nil
      expect(@event_type.nice_descr).to be_nil
    end
  end

end
