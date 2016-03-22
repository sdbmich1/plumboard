require 'spec_helper'

describe PixiPostZip do
  before(:each) do
    @pixi_post_zip = FactoryGirl.create(:pixi_post_zip) 
  end

  subject { @pixi_post_zip }

  it { is_expected.to respond_to(:city) }
  it { is_expected.to respond_to(:state) }
  it { is_expected.to respond_to(:zip) }
  it { is_expected.to respond_to(:status) }

  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_presence_of(:zip) }

  describe "active zips" do
    it { expect(PixiPost.active).not_to be_nil } 

    it "returns no inactive zips" do 
      @pixi_post_zip.status = 'inactive'
      @pixi_post_zip.save
      expect(PixiPost.active).to be_empty  
    end
  end
end
