require 'spec_helper'

shared_examples "model attributes" do
  describe 'assessible', base: true do
    unless attr.blank?
      attr.each do |fld, val| 
        it { should respond_to(fld.to_sym) }
      end
    end
  end
end

shared_examples "model methods" do |arr|
  describe 'defined methods', base: true do
    arr.each do |fld| 
      it { should respond_to(fld.to_sym) }
    end
  end
end

shared_examples "an amount" do |fld, max_amt|
  describe 'attributes', amt: true do
    it { should allow_value(5.00).for(fld.to_sym) }
    it { should allow_value(max_amt).for(fld.to_sym) }
    it { should_not allow_value(500000).for(fld.to_sym) }
    it { should_not allow_value(5000.001).for(fld.to_sym) }
    it { should_not allow_value(-5000.00).for(fld.to_sym) }
    it { should_not allow_value('$5000.0').for(fld.to_sym) }
    it { should_not allow_value('50.0%').for(fld.to_sym) }
  end
end

shared_examples "an address" do
  describe 'attributes', base: true do
    it { should respond_to(:address) }
    it { should respond_to(:address2) }
    it { should respond_to(:home_phone) }
    it { should respond_to(:work_phone) }
    it { should respond_to(:mobile_phone) }
    it { should respond_to(:city) }
    it { should respond_to(:state) }
    it { should respond_to(:zip) }
    it { should respond_to(:country) }
    it { should ensure_length_of(:zip).is_at_least(5).is_at_most(10) }
    it { should allow_value(41572).for(:zip) }
    it { should_not allow_value(725).for(:zip) }

    context 'phone number' do
      %w(home_phone work_phone mobile_phone).each do |phone|
        it { should ensure_length_of(phone.to_sym).is_at_least(10).is_at_most(15) }
        it { should allow_value(4157251111).for(phone.to_sym) }
        it { should_not allow_value('4157251111abcdefg').for(phone.to_sym) }
        it { should_not allow_value(7251111).for(phone.to_sym) }
      end
    end
  end
end

shared_examples 'a full address' do |model|
  describe "full address", address: true do
    before { @contact = model }
    it 'has address' do
      addr = [@contact.address, @contact.city, @contact.state].compact.join(', ') + ' ' + [@contact.zip, @contact.country].compact.join(', ')
      expect(@contact.full_address).to eq(addr)
    end

    it 'has no address' do
      @contact.address = @contact.city = @contact.state = @contact.zip = @contact.country = nil
      expect(@contact.full_address).to be_empty
    end
  end
end

shared_examples "an ID" do |fld|
  describe 'attributes', base: true do
    it { should allow_value(1).for(fld.to_sym) }
    # it { should_not allow_value("a").for(fld.to_sym) }
    it { should_not allow_value("").for(fld.to_sym) }
  end
end

shared_examples "a date" do |fld|
  describe 'attributes', base: true do
    it { should allow_value(Time.now).for(fld.to_sym) }
    # it { should_not allow_value("").for(fld.to_sym) }
  end
end

shared_examples "a status field" do |factory, fld|
  describe 'attributes', base: true do
    let(:model) { FactoryGirl.build factory, status: fld }
    it { expect(model.send([fld, '?'].join(''))).to be_true }
    it { expect(model.status).to eq fld }
  end
end

shared_examples "a url" do |klass, factory, flg|
  describe 'attributes', base: true do
    if flg
      let(:model) { FactoryGirl.create factory }
    else
      let(:model) { FactoryGirl.create factory, org_type: 'pub' }
    end
    it { expect(klass.constantize.get_by_url(model.url)).not_to be_blank }
    it { expect(klass.constantize.get_by_url('abcd')).to be_blank }
  end
end

shared_examples "an user" do
  describe 'attributes', base: true do
    it { should respond_to(:first_name) }
    it { should respond_to(:last_name) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should respond_to(:email) }
    it { should allow_value('Tom').for(:first_name) }
    it { should_not allow_value("a" * 31).for(:first_name) }
    it { should_not allow_value('').for(:first_name) }
    it { should_not allow_value('@@@').for(:first_name) }
    it { should allow_value('Tom').for(:last_name) }
    it { should_not allow_value("a" * 81).for(:last_name) }
    it { should_not allow_value('').for(:last_name) }
    it { should_not allow_value('@@@').for(:last_name) }

    context 'email' do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |invalid_address|
        it { should_not allow_value(invalid_address).for(:email) }
      end
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        it { should allow_value(valid_address).for(:email) }
      end
    end
  end
end
