require 'spec_helper'

describe SiteType do

  before(:each) do
    @site_type = build(:site_type)
  end
  
  subject { @site_type }

  it { should respond_to(:description) }
  it { should respond_to(:code) }
  it { should respond_to(:hide) }
  it { should respond_to(:status) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:hide) }
  it { should validate_presence_of(:status) }

  it { should have_many(:sites).with_foreign_key('site_type_code') }

  describe "active site_types" do
    before { create(:site_type, status: 'active') }
    it { SiteType.active.should_not be_nil }
  end

  describe "inactive site_types" do
    before { create(:site_type, status: 'inactive') }
    it { SiteType.active.should be_empty }
  end

  describe "hidden site_types" do
    before { create(:site_type, hide: 'yes') }
    it { SiteType.unhidden.should be_empty }
  end

  describe "unhidden site_types" do
    before { create(:site_type, hide: 'no') }
    it { SiteType.unhidden.should_not be_nil }
  end

  describe 'nice_descr' do
    it { @site_type.nice_descr.should == @site_type.description.titleize }

    it 'does not return titleized description' do
      @site_type.description = nil
      @site_type.nice_descr.should be_nil
    end
  end
end
