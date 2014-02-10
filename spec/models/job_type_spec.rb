require 'spec_helper'

describe JobType do
  before(:each) do
    @job_type = FactoryGirl.build(:job_type)
  end

  subject { @job_type }

  it { should respond_to(:job_name) }
  it { should respond_to(:status) }
  it { should respond_to(:code) }
  it { should validate_presence_of(:job_name) }
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:code) }

  describe "active job_types" do
    before { FactoryGirl.create(:job_type) }
    it { JobType.active.should_not be_nil } 
  end

  describe "inactive job_types" do
    before { FactoryGirl.create(:job_type, status: 'inactive') }
    it { JobType.active.should be_empty } 
  end
end
