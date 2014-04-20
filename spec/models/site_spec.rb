require 'spec_helper'

describe Site do
  before(:each) do
    @user = create :pixi_user
    @listing = create(:listing, seller_id: @user.id) 
    @site = @listing.site 
  end
   
  subject { @site } 

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:org_type) }
  it { should respond_to(:status) }
  it { should respond_to(:institution_id) }
  it { should respond_to(:users) }
  it { should respond_to(:site_users) }
  it { should respond_to(:site_listings) }
  it { should respond_to(:listings) }
  it { should respond_to(:contacts) }
  it { should respond_to(:pictures) }
  it { should respond_to(:temp_listings) }

  describe "should include active sites" do
    it { Site.active.should_not be_nil }
  end

  describe "should not include inactive sites" do
    site = Site.create(:name=>'Item', :status=>'inactive')
    it { Site.active.should_not include (site) } 
  end

  describe "when name is empty" do
    before { @site.name = "" }
    it { should_not be_valid }
  end

  describe 'active pixis' do
    site = Site.create(:name=>'Item', :status=>'inactive')
    it { Site.active_with_pixis.should_not include (site) } 
    it { Site.active_with_pixis.should include (@site) } 
  end

  describe 'pictures' do
    before(:each) do
      @sr = @site.pictures.create FactoryGirl.attributes_for(:picture)
    end

    it "should have a pictures method" do
      @site.should respond_to(:pictures)
    end
				            
    it "has many pictures" do 
      @site.pictures.should include(@sr)
    end

    it "should destroy associated pictures" do
      @site.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
    end  
  end  

  describe 'contacts' do
    before(:each) do
      @sr = @site.contacts.create FactoryGirl.attributes_for(:contact) 
    end

    context "should have a contacts method" do
      it { should respond_to(:contacts) }
    end

    it "has many contacts" do 
      @site.contacts.should include(@sr)
    end

    it "should destroy associated contacts" do
      @site.destroy
      [@sr].each do |s|
         Contact.find_by_id(s.id).should be_nil
       end
    end  
  end  

  describe 'get_by_type' do
    it 'returns sites' do
      create :site, name: 'San Francisco State', org_type: 'school'
      expect(Site.get_by_type('school')).not_to be_empty 
    end  

    it 'does not return sites' do
      expect(Site.get_by_type('school')).to be_empty 
    end  
  end

  describe 'cities' do
    it 'returns sites' do
      create :site, name: 'San Francisco', org_type: 'city'
      expect(Site.cities).not_to be_empty 
    end  

    it 'does not return sites' do
      expect(Site.cities).to be_empty 
    end  
  end

  describe 'check_site' do
    it 'locates sites' do
      @site1 = create :site, name: 'Detroit', org_type: 'city'
      @site1.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI'
      expect(Site.check_site @site1.id, 'city').not_to be_nil 
    end

    it 'does not return sites' do
      expect(Site.check_site @site.id, 'city').to be_nil 
    end  
  end

  describe 'check types' do
    it 'is a city' do
      site = create :site, name: 'Detroit', org_type: 'city'
      expect(site.is_city?).to be_true
      expect(site.is_school?).not_to be_true
      expect(site.is_region?).not_to be_true
    end

    it 'is a school' do
      site = create :site, name: 'Detroit College', org_type: 'school'
      expect(site.is_school?).to be_true
      expect(site.is_city?).not_to be_true
      expect(site.is_region?).not_to be_true
    end

    it 'is a region' do
      site = create :site, name: 'Detroit', org_type: 'region'
      expect(site.is_region?).to be_true
      expect(site.is_school?).not_to be_true
      expect(site.is_city?).not_to be_true
    end
  end

end
