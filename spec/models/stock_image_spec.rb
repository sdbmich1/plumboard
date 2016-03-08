require 'spec_helper'

describe StockImage do
  before :all do
  	@stock_image = FactoryGirl.create(:stock_image)
  end

  subject { @stock_image }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:category_type_code) }
  it { is_expected.to respond_to(:file_name) }
end
