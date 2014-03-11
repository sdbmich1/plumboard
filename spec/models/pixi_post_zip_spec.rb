require 'spec_helper'

describe PixiPostZip do
  before(:each) do
    @pixi_post_zip = FactoryGirl.create(:pixi_post_zip) 
  end

  subject { @pixi_post_zip }

  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zip) }
  it { should respond_to(:status) }

  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:state) }
  it { should validate_presence_of(:zip) }

  describe "active zips" do
    it { PixiPost.active.should_not be_nil } 

    it "returns no inactive zips" do 
      @pixi_post_zip.status = 'inactive'
      @pixi_post_zip.save
      PixiPost.active.should be_empty  
    end
  end
end
