require 'spec_helper'

describe TravelMode do
  before(:each) do
    @travel_mode = build(:travel_mode)
  end

  subject { @travel_mode }

  it { should respond_to(:description) }
  it { should respond_to(:status) }
  it { should respond_to(:mode) }
  it { should respond_to(:travel_type) }
  it { should respond_to(:hide) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:mode) }
  it { should validate_presence_of(:travel_type) }

  describe "active travel_modes" do
    before { create(:travel_mode) }
    it { TravelMode.active.should_not be_nil } 
  end

  describe "inactive travel_modes" do
    before { create(:travel_mode, status: 'inactive') }
    it { TravelMode.active.should be_empty } 
  end

  describe "hidden travel_modes" do
    before { create(:travel_mode, mode: 'active', hide: 'yes') }
    it { TravelMode.unhidden.should be_empty } 
  end

  describe "unhidden travel_modes" do
    before { create(:travel_mode, mode: 'active', hide: 'no') }
    it { TravelMode.unhidden.should_not be_nil } 
  end

  describe 'descr_title' do
    it { expect(@travel_mode.descr_title).to eq @travel_mode.description.upcase }
    it 'returns nil' do
      @travel_mode.description = nil
      expect(@travel_mode.descr_title).to be_nil
    end
  end

  describe 'details' do
    it { expect(@travel_mode.details).to eq ['Travel Mode:', @travel_mode.description].join(' ') }
    it 'returns nil' do
      @travel_mode.description = nil
      expect(@travel_mode.details).to be_nil
    end
  end
end
