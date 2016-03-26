require 'spec_helper'

describe State do
  before(:each) do
    @state = FactoryGirl.build(:state) 
  end
   
  subject { @state }

  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:state_name) }

end
