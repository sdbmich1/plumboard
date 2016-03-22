require 'spec_helper'

describe SiteType do

  before(:each) do
    @site_type = build(:site_type)
  end
  
  subject { @site_type }

  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:hide) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:hide) }
  it { is_expected.to validate_presence_of(:status) }

  it { is_expected.to have_many(:sites).with_foreign_key('site_type_code') }

  describe "active site_types" do
    before { create(:site_type, status: 'active') }
    it { expect(SiteType.active).not_to be_nil }
  end

  describe "inactive site_types" do
    before { create(:site_type, status: 'inactive') }
    it { expect(SiteType.active).to be_empty }
  end

  describe "hidden site_types" do
    before { create(:site_type, hide: 'yes') }
    it { expect(SiteType.unhidden).to be_empty }
  end

  describe "unhidden site_types" do
    before { create(:site_type, hide: 'no') }
    it { expect(SiteType.unhidden).not_to be_nil }
  end

  describe 'nice_descr' do
    it { expect(@site_type.nice_descr).to eq(@site_type.description.titleize) }

    it 'does not return titleized description' do
      @site_type.description = nil
      expect(@site_type.nice_descr).to be_nil
    end
  end
end
