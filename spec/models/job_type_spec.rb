require 'spec_helper'

describe JobType do
  before(:each) do
    @job_type = FactoryGirl.build(:job_type)
  end

  subject { @job_type }

  it { is_expected.to respond_to(:job_name) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to validate_presence_of(:job_name) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:code) }

  it { is_expected.to have_many(:listings).with_foreign_key('job_type_code') }
  it { is_expected.to have_many(:temp_listings).with_foreign_key('job_type_code') }
  it { is_expected.to have_many(:old_listings).with_foreign_key('job_type_code') }

  describe "active job_types" do
    before { FactoryGirl.create(:job_type) }
    it { expect(JobType.active).not_to be_nil } 
  end

  describe "inactive job_types" do
    before { FactoryGirl.create(:job_type, status: 'inactive') }
    it { expect(JobType.active).to be_empty } 
  end
end
