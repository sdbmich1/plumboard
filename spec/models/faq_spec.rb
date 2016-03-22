require 'spec_helper'

describe Faq do
  before(:each) do
    @faq = FactoryGirl.build(:faq)
  end
   
  subject { @faq } 

  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:question_type) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:subject) }

  describe "should include active inquiries" do
    it { expect(Faq.active).not_to be_nil }
  end

  describe "should not include inactive inquiries" do
    faq = FactoryGirl.create(:faq, :status=>'inactive')
    it { expect(Faq.active).not_to include (faq) } 
  end

  describe 'set_flds' do
    it "sets status to active" do
      @faq = FactoryGirl.build(:faq, :status=>nil)
      @faq.save
      expect(@faq.status).to eq('active')
    end

    it "does not set status to active" do
      @faq = FactoryGirl.build(:faq, :status=>'inactive')
      @faq.save
      expect(@faq.status).not_to eq('active')
    end
  end

  describe 'summary' do
    it "should return a summary" do 
      expect(@faq.summary).to be_truthy 
    end

    it "should not return a summary" do 
      @faq.description = nil
      expect(@faq.summary).not_to be_truthy 
    end
  end
end
