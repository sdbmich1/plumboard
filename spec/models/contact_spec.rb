require 'spec_helper'

describe Contact do
  before(:each) do
    @contact = FactoryGirl.build(:contact) 
  end

  it { should respond_to(:address) }
  it { should respond_to(:address2) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:zip) }
  it { should respond_to(:county) }
  it { should respond_to(:work_phone) }
  it { should respond_to(:home_phone) }
  it { should respond_to(:mobile_phone) }
  it { should respond_to(:website) }
  it { should respond_to(:country) }
  it { should respond_to(:lng) }
  it { should respond_to(:lat) }
  it { should respond_to(:contactable) }
  it { should ensure_length_of(:zip).is_equal_to(5) }
  it { should ensure_length_of(:home_phone).is_at_least(10).is_at_most(15) }
  it { should ensure_length_of(:mobile_phone).is_at_least(10).is_at_most(15) }
  it { should ensure_length_of(:work_phone).is_at_least(10).is_at_most(15) }

  it { should allow_value(4157251111).for(:home_phone) }
  it { should allow_value(4157251111).for(:work_phone) }
  it { should allow_value(4157251111).for(:mobile_phone) }
  it { should_not allow_value(7251111).for(:home_phone) }
  it { should_not allow_value(7251111).for(:work_phone) }
  it { should_not allow_value(7251111).for(:mobile_phone) }
  it { should_not allow_value(4157251111234567).for(:mobile_phone) }
  it { should allow_value(41572).for(:zip) }
  it { should_not allow_value(725).for(:zip) }

  describe "when city is invalid" do
    before { @contact.city = "@@@@" }
    it { should_not be_valid }
  end

  describe "when city is empty" do
    before { @contact.city = "" }
    it { should_not be_valid }
  end

  describe "when state is empty" do
    before { @contact.state = "" }
    it { should_not be_valid }
  end

  describe "full address" do
    it 'has address' do
      addr = [@contact.address, @contact.city, @contact.state].compact.join(', ') + ' ' + [@contact.zip, @contact.country].compact.join(', ')
      expect(@contact.full_address).to eq(addr)
    end

    it 'has no address' do
      @contact.address = @contact.city = @contact.state = @contact.zip = @contact.country = nil
      expect(@contact.full_address).to be_empty
    end
  end

  describe 'get_sites' do
    it 'locates sites' do
      @site = create :site, name: 'Detroit', org_type: 'city'
      @site1 = create :site, name: 'Detroit City College', org_type: 'school'
      @site2 = create :site, name: 'Greektown', org_type: 'area'
      @site.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI'
      @site1.contacts.create FactoryGirl.attributes_for :contact, address: '1000 Michigan Ave', city: 'Detroit', state: 'MI'
      @site2.contacts.create FactoryGirl.attributes_for :contact, address: '100 State', city: 'Detroit', state: 'MI', zip: '48214'
      expect(Contact.get_sites('Detroit', 'MI').count).to eq(3)
    end

    it 'does not locate sites' do
      expect(Contact.get_sites('Detroit', 'MI').count).to eq(0)
    end
  end

end
