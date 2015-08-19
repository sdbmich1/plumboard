require 'spec_helper'

describe StockImage do
  before :all do
  	@stock_image = FactoryGirl.create(:stock_image)
  end

  subject { @stock_image }
  it { should respond_to(:title) }
  it { should respond_to(:category_type_code) }
  it { should respond_to(:file_name) }
end
