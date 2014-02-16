require 'spec_helper'

describe Faq do
  before(:each) do
    @faq = FactoryGirl.build(:faq)
  end
   
  subject { @faq } 

  it { should respond_to(:description) }
  it { should respond_to(:question_type) }
  it { should respond_to(:status) }
  it { should respond_to(:subject) }

  describe "should include active inquiries" do
    it { Faq.active.should_not be_nil }
  end

  describe "should not include inactive inquiries" do
    faq = FactoryGirl.create(:faq, :status=>'inactive')
    it { Faq.active.should_not include (faq) } 
  end

  describe 'set_flds' do
    it "sets status to active" do
      @faq = FactoryGirl.build(:faq, :status=>nil)
      @faq.save
      @faq.status.should == 'active'
    end

    it "does not set status to active" do
      @faq = FactoryGirl.build(:faq, :status=>'inactive')
      @faq.save
      @faq.status.should_not == 'active'
    end
  end
end
