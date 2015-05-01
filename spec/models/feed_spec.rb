require 'spec_helper'

describe Feed do
  before :each do
    @feed = create :feed
  end

  subject { @feed }
  describe 'attributes', base: true do
    its(:attributes) { should include(*%w(description site_id site_name status url)) }
    it { should validate_presence_of(:url) }
  end
end