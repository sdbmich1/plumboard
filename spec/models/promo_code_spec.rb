require 'spec_helper'

describe PromoCode do
  before(:each) do
    @promo_code = FactoryGirl.create(:promo_code)
  end

  subject { @promo_code }

  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:promo_name) }
  it { is_expected.to respond_to(:start_date) }
  it { is_expected.to respond_to(:start_time) }
  it { is_expected.to respond_to(:end_date) }
  it { is_expected.to respond_to(:end_time) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:currency) }
  it { is_expected.to respond_to(:promo_type) }
  it { is_expected.to respond_to(:site_id) }
  it { is_expected.to respond_to(:owner_id) }
  it { is_expected.to respond_to(:amountOff) }
  it { is_expected.to respond_to(:percentOff) }
  it { is_expected.to respond_to(:max_redemptions) }
  it { is_expected.to respond_to(:site) }
  it { is_expected.to respond_to(:pictures) }
  it { is_expected.to respond_to(:user) }

  describe "when code is entered" do
    before { @promo_code.code = "chair" }
    it { expect(@promo_code.code).to eq("chair") }
  end

  describe "when both amountOff & percentOff is empty" do
    before { @promo_code.amountOff = @promo_code.percentOff = nil }
    it { is_expected.not_to be_valid }
  end

  describe "when only percentOff is empty" do
    before { @promo_code.amountOff, @promo_code.percentOff = 20, nil }
    it { is_expected.to be_valid }
  end

  describe "when only amountOff is empty" do
    before { @promo_code.amountOff, @promo_code.percentOff = nil, 20 }
    it { is_expected.to be_valid }
  end

  describe "end_date should not exist when start_date is empty" do
    before { @promo_code.start_date, @promo_code.end_date = nil, nil }
    it { is_expected.to be_valid }
  end

  describe "end_date should exist when start_date exists" do
    before { @promo_code.start_date, @promo_code.end_date = Date.today, Date.today+1.day }
    it { is_expected.to be_valid }
  end

  describe "end_date should not be less than start_date" do
    before { @promo_code.start_date, @promo_code.end_date = Date.today, Date.today-1.day }
    it { is_expected.not_to be_valid }
  end

  describe "end_date should exist when start_date is not empty" do
    before { @promo_code.start_date, @promo_code.end_date = Date.today, nil }
    it { is_expected.not_to be_valid }
  end

  describe "start_date should exist when end_date is not empty" do
    before { @promo_code.start_date, @promo_code.end_date = nil, Date.today }
    it { is_expected.not_to be_valid }
  end

  describe "end_time should not exist when start_time is empty" do
    before { @promo_code.start_time, @promo_code.end_time = nil, nil }
    it { is_expected.to be_valid }
  end

  describe "end_time should exist when start_time exists" do
    before { @promo_code.start_time, @promo_code.end_time = Time.now, Time.now+1.hour }
    it { is_expected.to be_valid }
  end

  describe "end_time should exist when start_time is not empty" do
    before { @promo_code.start_time, @promo_code.end_time = Time.now, nil }
    it { is_expected.not_to be_valid }
  end

  describe "start_time should exist when end_time is not empty" do
    before { @promo_code.start_time, @promo_code.end_time = nil, Time.now }
    it { is_expected.not_to be_valid }
  end

  describe "compare start time vs end time" do
    before do
      @promo_code.start_date = @promo_code.end_date = Date.today
    end

    it "start_time can not equal end_time on same day" do
      @promo_code.start_time = @promo_code.end_time = Time.now
      expect(@promo_code).not_to be_valid
    end

    it "start_time can not be greater than end_time on same day" do
      @promo_code.start_time, @promo_code.end_time = Time.now, Time.now-1.hour
      expect(@promo_code).not_to be_valid
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
      expect(promo_code).to be_valid
    end

    it "start_time can be less than end_time when not same day" do
      promo_code.start_time, promo_code.end_time = Time.now, Time.now-1.hour
      promo_code.save
      expect(promo_code).to be_valid
    end
  end

  describe "when promo_name is empty" do
    before { @promo_code.promo_name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when promo_name is entered" do
    before { @promo_code.promo_name = "chair" }
    it { expect(@promo_code.promo_name).to eq("chair") }
  end

  describe "should not include inactive promo_codes" do
    promo_code = FactoryGirl.create :promo_code, :description=>'stuff', :status=>'inactive'
    it { expect(PromoCode.active).not_to include (promo_code) }
  end

  describe "should include active promo_codes" do
    it { expect(PromoCode.active).to be_truthy }
  end

  describe "should not return expired promo codes"  do
    promo_code = FactoryGirl.create :promo_code, start_date: '2013-01-01'.to_date, end_date: '2013-02-28'.to_date
    it { expect(PromoCode.get_valid_code(promo_code, Date.today)).not_to eq([@promo_code]) }
  end

  it "should return promo codes" do
    promo_code = FactoryGirl.create :promo_code, start_date: '2013-01-01'.to_date, end_date: Date.today
    expect(PromoCode.get_valid_code(promo_code, Date.today)).not_to be_nil
  end

  describe "same_day? should be true" do
    before { @promo_code.start_date = @promo_code.end_date = Date.today }
    it { expect(@promo_code.same_day?).to be_truthy }
  end

  describe "same_day? should not be true" do
    before { @promo_code.start_date, @promo_code.end_date = Date.today, Date.today+1.day }
    it { expect(@promo_code.same_day?).not_to be_truthy }
  end

  describe "has_start_time? should be true" do
    before { @promo_code.start_time = Date.today }
    it { expect(@promo_code.has_start_time?).to be_truthy }
  end

  describe "has_start_time? should not be true" do
    before { @promo_code.start_time = nil }
    it { expect(@promo_code.has_start_time?).not_to be_truthy }
  end

  describe 'check promos' do
    it "get code should return promo" do
      promo_code = FactoryGirl.create :promo_code, code: 'test', start_date: '2013-01-01'.to_date, end_date: Date.today
      expect(PromoCode.get_code(promo_code.code, Date.today)).not_to be_nil
    end

    it "get code should not return promo" do
      promo_code = FactoryGirl.create :promo_code, start_date: '2013-01-01'.to_date, end_date: '2013-03-28'.to_date
      expect(PromoCode.get_code('Test', Date.today)).to be_nil
    end
  end

  describe 'local promos' do
    before :each do
      @user = create(:business_user, status: 'active')
      @code = @user.promo_codes.create attributes_for(:promo_code)
    end
    it { expect(PromoCode.get_local_promos('90201')).not_to be_nil } 
    it { expect(PromoCode.get_local_promos('90202')).not_to include @code } 
  end

  describe 'user promos' do
    before :each do
      @user = create(:business_user, status: 'active')
      @code = @user.promo_codes.create attributes_for(:promo_code)
      @user2 = create(:business_user, first_name: 'Jak', last_name: 'Test', business_name: 'The Hive', status: 'active')
      @code2 = @user2.promo_codes.create attributes_for(:promo_code)
    end
    it { expect(PromoCode.get_user_promos(@user)).not_to be_nil } 
    it { expect(PromoCode.get_user_promos(@user2)).not_to include @code } 
    it { expect(PromoCode.get_user_promos(@user2, true).count).not_to eq 1 } 
  end
end
