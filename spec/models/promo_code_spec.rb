require 'spec_helper'

describe PromoCode do
  before(:each) do
    @promo_code = FactoryGirl.create(:promo_code)
  end

  subject { @promo_code }

  it { should respond_to(:code) }
  it { should respond_to(:promo_name) }
  it { should respond_to(:start_date) }
  it { should respond_to(:start_time) }
  it { should respond_to(:end_date) }
  it { should respond_to(:end_time) }
  it { should respond_to(:description) }
  it { should respond_to(:status) }
  it { should respond_to(:currency) }
  it { should respond_to(:promo_type) }
  it { should respond_to(:site_id) }
  it { should respond_to(:amountOff) }
  it { should respond_to(:percentOff) }
  it { should respond_to(:max_redemptions) }
  it { should respond_to(:site) }

  describe "when code is empty" do
    before { @promo_code.code = "" }
    it { should_not be_valid }
  end

  describe "when code is entered" do
    before { @promo_code.code = "chair" }
    it { @promo_code.code.should == "chair" }
  end

  describe "when both amountOff & percentOff is empty" do
    before { @promo_code.amountOff = @promo_code.percentOff = nil }
    it { should_not be_valid }
  end

  describe "when only percentOff is empty" do
    before { @promo_code.amountOff, @promo_code.percentOff = 20, nil }
    it { should be_valid }
  end

  describe "when only amountOff is empty" do
    before { @promo_code.amountOff, @promo_code.percentOff = nil, 20 }
    it { should be_valid }
  end

  describe "end_date should not exist when start_date is empty" do
    before { @promo_code.start_date, @promo_code.end_date = nil, nil }
    it { should be_valid }
  end

  describe "end_date should exist when start_date exists" do
    before { @promo_code.start_date, @promo_code.end_date = Date.today, Date.today+1.day }
    it { should be_valid }
  end

  describe "end_date should not be less than start_date" do
    before { @promo_code.start_date, @promo_code.end_date = Date.today, Date.today-1.day }
    it { should_not be_valid }
  end

  describe "end_date should exist when start_date is not empty" do
    before { @promo_code.start_date, @promo_code.end_date = Date.today, nil }
    it { should_not be_valid }
  end

  describe "start_date should exist when end_date is not empty" do
    before { @promo_code.start_date, @promo_code.end_date = nil, Date.today }
    it { should_not be_valid }
  end

  describe "end_time should not exist when start_time is empty" do
    before { @promo_code.start_time, @promo_code.end_time = nil, nil }
    it { should be_valid }
  end

  describe "end_time should exist when start_time exists" do
    before { @promo_code.start_time, @promo_code.end_time = Time.now, Time.now+1.hour }
    it { should be_valid }
  end

  describe "end_time should exist when start_time is not empty" do
    before { @promo_code.start_time, @promo_code.end_time = Time.now, nil }
    it { should_not be_valid }
  end

  describe "start_time should exist when end_time is not empty" do
    before { @promo_code.start_time, @promo_code.end_time = nil, Time.now }
    it { should_not be_valid }
  end

  describe "compare start time vs end time" do
    before do
      @promo_code.start_date = @promo_code.end_date = Date.today
    end

    it "start_time can not equal end_time on same day" do
      @promo_code.start_time = @promo_code.end_time = Time.now
      @promo_code.should_not be_valid
    end

    it "start_time can not be greater than end_time on same day" do
      @promo_code.start_time, @promo_code.end_time = Time.now, Time.now-1.hour
      @promo_code.should_not be_valid
    end
  end

  describe "compare time" do
    let(:promo_code) { FactoryGirl.build :promo_code }
    before do
      promo_code.start_date, promo_code.end_date = Date.today, Date.today+1.day
    end

    it "start_time can equal end_time when not same day" do
      promo_code.start_time = promo_code.end_time = Time.now
      promo_code.save
      promo_code.should be_valid
    end

    it "start_time can be less than end_time when not same day" do
      promo_code.start_time, promo_code.end_time = Time.now, Time.now-1.hour
      promo_code.save
      promo_code.should be_valid
    end
  end

  describe "when promo_name is empty" do
    before { @promo_code.promo_name = "" }
    it { should_not be_valid }
  end

  describe "when promo_name is entered" do
    before { @promo_code.promo_name = "chair" }
    it { @promo_code.promo_name.should == "chair" }
  end

  describe "should not include inactive promo_codes" do
    promo_code = FactoryGirl.create :promo_code, :description=>'stuff', :status=>'inactive'
    it { PromoCode.active.should_not include (promo_code) }
  end

  describe "should include active promo_codes" do
    it { PromoCode.active.should be_true }
  end

  describe "should not return expired promo codes"  do
    promo_code = FactoryGirl.create :promo_code, start_date: '2013-01-01'.to_date, end_date: '2013-02-28'.to_date
    it { PromoCode.get_valid_code(promo_code, Date.today).should_not == [@promo_code] }
  end

  it "should return promo codes" do
    promo_code = FactoryGirl.create :promo_code, start_date: '2013-01-01'.to_date, end_date: Date.today
    PromoCode.get_valid_code(promo_code, Date.today).should_not be_nil
  end

  describe "same_day? should be true" do
    before { @promo_code.start_date = @promo_code.end_date = Date.today }
    it { @promo_code.same_day?.should be_true }
  end

  describe "same_day? should not be true" do
    before { @promo_code.start_date, @promo_code.end_date = Date.today, Date.today+1.day }
    it { @promo_code.same_day?.should_not be_true }
  end

  describe "has_start_time? should be true" do
    before { @promo_code.start_time = Date.today }
    it { @promo_code.has_start_time?.should be_true }
  end

  describe "has_start_time? should not be true" do
    before { @promo_code.start_time = nil }
    it { @promo_code.has_start_time?.should_not be_true }
  end

  it "get code should return promo" do
    promo_code = FactoryGirl.create :promo_code, code: 'test', start_date: '2013-01-01'.to_date, end_date: Date.today
    PromoCode.get_code(promo_code.code, Date.today).should_not be_nil
  end

  it "get code should not return promo" do
    promo_code = FactoryGirl.create :promo_code, start_date: '2013-01-01'.to_date, end_date: '2013-03-28'.to_date
    PromoCode.get_code('Test', Date.today).should be_nil
  end
end
