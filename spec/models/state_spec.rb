require 'spec_helper'

describe State do
  before(:each) do
    @state = FactoryGirl.build(:state) 
  end
   
  subject { @state }

  it { should respond_to(:code) }
  it { should respond_to(:state_name) }

end
