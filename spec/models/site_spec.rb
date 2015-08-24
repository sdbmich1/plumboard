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
  it { should respond_to(:site_type_code) }
  it { should respond_to(:status) }
  it { should respond_to(:institution_id) }
  it { should respond_to(:users) }
  it { should respond_to(:site_users) }
  it { should respond_to(:listings) }
  it { should respond_to(:contacts) }
  it { should respond_to(:pictures) }
  it { should respond_to(:temp_listings) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:site_type_code) }

  it {should belong_to(:site_type).with_foreign_key('site_type_code') }

  describe "should include active sites" do
    it { Site.active.should_not be_nil }
  end

  describe "should not include inactive sites" do
    site = Site.create(:name=>'Item', :status=>'inactive')
    it { Site.active.should_not include (site) } 
  end

  describe "should not include sites with invalid site_type_code" do
    ['region', 'state', 'country'].each { |name|
      site = FactoryGirl.create(:site, name: 'Item', status: 'inactive', site_type_code: name)
      it { Site.active(false).should_not include (site) }
    }
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
      create :site, name: 'San Francisco State', site_type_code: 'school'
      expect(Site.get_by_type('school')).not_to be_empty 
    end  

    it 'does not return sites' do
      expect(Site.get_by_type('region')).to be_empty 
    end  
  end

  describe 'get_by_name_and_type' do
    it 'returns sites' do
      create :site, name: 'San Francisco State', site_type_code: 'school'
      expect(Site.get_by_name_and_type('San Francisco State', 'school')).not_to be_empty 
    end  

    it 'does not return sites w/o name' do
      expect(Site.get_by_name_and_type(nil, 'school')).to be_empty 
    end  

    it 'does not return sites w/o type' do
      expect(Site.get_by_name_and_type('San Francisco State', nil)).to be_empty 
    end  
  end

  describe 'get_by_status' do
    it 'returns sites' do
      create :site, name: 'San Francisco State', site_type_code: 'school'
      expect(Site.get_by_status('active')).not_to be_empty
      create :site, name: 'San Francsico', site_type_code: 'city', status: 'inactive'
      expect(Site.get_by_status('inactive')).not_to be_empty
    end
    
    it 'does not return sites' do
      expect(Site.get_by_type('inactive')).to be_empty
    end
  end

  describe 'cities' do
    it 'returns sites' do
      create :site, name: 'San Francisco', site_type_code: 'city'
      expect(Site.cities).not_to be_empty 
    end  

    it 'does not return sites' do
      expect(Site.cities).to be_empty 
    end  
  end

  describe 'check_site' do
    it 'locates sites' do
      @site1 = create :site, name: 'Detroit', site_type_code: 'city'
      @site1.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI'
      expect(Site.check_site @site1.id, 'city').not_to be_nil 
    end

    it 'does not return sites' do
      expect(Site.check_site @site.id, 'city').to be_nil 
    end  
  end

  describe 'check types' do
    it 'is a city' do
      site = create :site, name: 'Detroit', site_type_code: 'city'
      expect(site.is_city?).to be_true
      expect(site.is_school?).not_to be_true
      expect(site.is_region?).not_to be_true
    end

    it 'is a school' do
      site = create :site, name: 'Detroit College', site_type_code: 'school'
      expect(site.is_school?).to be_true
      expect(site.is_city?).not_to be_true
      expect(site.is_region?).not_to be_true
    end

    it 'is a region' do
      site = create :site, name: 'Detroit', site_type_code: 'region'
      expect(site.is_region?).to be_true
      expect(site.is_school?).not_to be_true
      expect(site.is_city?).not_to be_true
    end

    it 'is a pub' do
      site = create :site, name: 'City Living', site_type_code: 'pub'
      expect(site.is_pub?).to be_true
      expect(site.is_region?).not_to be_true
      expect(site.is_school?).not_to be_true
      expect(site.is_city?).not_to be_true
    end
  end

  describe 'get_nearest_region' do
    before(:each, :run => true) do
      @site1 = create :site, name: 'Ann Arbor', org_type: 'city'
      @site1.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro',
        city: 'Ann Arbor', state: 'MI', zip: '48103', lat: 42.22, lng: -83.75
      @site2 = create :site, name: 'Metro Detroit', org_type: 'region'
      @site2.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro',
        city: 'Detroit', state: 'MI', zip: '48238', lat: 42.23, lng: -83.33
    end

    it "finds nearest region", :run => true do
      expect(Site.get_nearest_region([@site1.contacts.first.lat, @site1.contacts.first.lng])).to include 'Metro Detroit'
    end

    it "doesn't find nearest region" do
      @site3 = create :site, name: 'SF Bay Area', org_type: 'region'
      @site3.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro',
        city: 'San Francisco', state: 'CA', zip: '94101', lat: 37.77, lng: -122.43
      expect(Site.get_nearest_region([nil, nil])).to include('SF Bay Area')
      expect(Site.get_nearest_region('')).to include('SF Bay Area')
    end
  end

  describe 'check_site_type_code' do

    it 'finds site w/ site type code' do
      site = create :site, name: 'Detroit', site_type_code: 'region'
      expect(Site.check_site_type_code(['city','region'])).not_to be_nil
    end

    it 'does not find site w/ site type code' do
      site = create :site, name: 'Detroit', site_type_code: 'region'
      expect(Site.check_site_type_code(['city'])).to be_empty
    end
  end
  
  describe 'get_site' do
    it 'should return site' do
      site = create :site, name: 'Berkeley', site_type_code: 'city'
      Site.get_site(site.id).first.name.should == 'Berkeley'
    end

    it 'should not return invalid site' do
      expect(Site.get_site(123456789)).to be_empty
    end
  end

  describe 'regions' do
    before(:each) do
      Geocoder.configure(:timeout => 30)
    end
    
    cities = {
      'New York Metropolitan Area' => ['New York City', 'NY', 'Rye', 'New Rochelle', 'Poughkeepsie', 'Newburgh'],
      'Los Angeles Metropolitan Area' => ['Los Angeles', 'CA', 'Anaheim', 'Santa Ana', 'Irvine', 'Huntington Beach', 'Santa Clarita'],
      'Chicagoland' => ['Chicago', 'IL', 'Arlington Heights', 'Berwyn', 'Cicero', 'DeKalb', 'Des Plaines', 'Evanston'],
      'Dallas/Fort Worth Metroplex' => ['Dallas', 'TX', 'Fort Worth', 'Arlington', 'Plano', 'Irving', 'Frisco', 'McKinney', 'Carrollton', 'Garland', 'Richardson'],
      'Greater Houston' => ['Houston', 'TX', 'The Woodlands', 'Sugar Land', 'Baytown', 'Conroe'],
      'Delaware Valley' => ['Philadelphia', 'PA', 'Philadelphia', 'Reading'],
      'Washington Metropolitan Area' => ['Washington', 'D.C.', 'Washington'],
      'Miami Metropolitan Area' => ['Miami', 'FL', 'Fort Lauderdale', 'Hialeah', 'Miramar', 'Pembroke Pines'],
      'Metro Atlanta' => ['Atlanta', 'GA', 'Sandy Springs', 'Roswell', 'Johns Creek', 'Alpharetta', 'Marietta', 'Smyrna'],
      'Greater Boston' => ['Boston', 'MA', 'Boston', 'Cambridge', 'Framingham', 'Quincy'],
      'Valley of the Sun' => ['Phoenix', 'AZ', 'Mesa', 'Chandler', 'Glendale', 'Scottsdale', 'Gilbert'],
      'Seattle Metro' => ['Seattle', 'WA', 'Tacoma', 'Bellevue', 'Everett'],
      'Minneapolis-Saint Paaul' => ['Minneapolis', 'MN', 'Saint Paul', 'Bloomington', 'Brooklyn Park', 'Plymouth'],
      'San Diego County' => ['San Diego', 'CA', 'Carlsbad', 'Chula Vista', 'Escondido', 'Oceanside'],
      'Tampa Bay Area' => ['Tampa', 'FL', 'St. Petersburg', 'Clearwater', 'Brandon'],
      'Greater St. Louis' => ['St. Louis', 'MO', 'Berger', 'Arnold', 'Barnhart', 'Cottleville'],
      'Central Maryland' => ['Baltimore', 'MD', 'Columbia', 'Towson'],
      'Denver Metropolitan Area' => ['Denver', 'CO', 'Arvada', 'Aurora', 'Centennial'],
      'Pittsburgh Metropolitan Area' => ['Pittsburgh', 'PA', 'Indiana', 'Jeannette', 'Latrobe', 'Lower Burrell'],
      'Charlotte Metro' => ['Charlotte', 'NC', 'Concord', 'Gastonia', 'Cornelius'],
      'Portland Metropolitan Area' => ['Portland', 'OR', 'Beaverton', 'Gresham', 'Hillsboro'],
      'Greater San Antonio' => ['San Antonio', 'TX', 'New Braunfels', 'Schertz', 'Seguin'],
      'Metro Orlando' => ['Orlando', 'FL', 'Kissimmee', 'Sanford', 'Tavares'],
      'Greater Sacramento' => ['Sacramento', 'CA', 'Yuba City', 'South Lake Tahoe'],
      'Greater Cincinnati' => ['Cincinnati', 'OH', 'Mason'],
      'Greater Cleveland' => ['Cleveland', 'OH', 'Parma', 'Lorain', 'Elyria', 'Lakewood'],
      'Kansas City Metropolitan Area' => ['Kansas City', 'MO', 'Independence', "Lee's Summit"],
      'Las Vegas Metropolitan Area' => ['Las Vegas', 'NV', 'Paradise', 'Henderson', 'Boulder City'],
      'Columbus Metropolitan Area' => ['Columbus', 'OH', 'Delaware', 'Newark', 'Lancaster', 'London'],
      'Greater Indianapolis' => ['Indianapolis', 'IN', 'Carmel', 'Greenwood', 'Noblesville'],
      'Greater Austin' => ['Austin', 'TX', 'Round Rock', 'Cedar Park', 'San Marcos', 'Georgetown'],
      'Nashville Metropolitan Area' => ['Nashville', 'TN', 'Murfreesboro', 'Franklin', 'Hendersonville'],
      'Hampton Roads' => ['Virginia Beach', 'VA', 'Norfolk', 'Chesapeake', 'Newport News'],
      'Providence Metropolitan Area' => ['Providence', 'RI', 'Warwick', 'Cranston'],
      'Metro Milwaukee' => ['Milwaukee', 'WI', 'Racine', 'Waukesha'],
      'Metro Jacksonville' => ['Jacksonville', 'FL', 'St. Augustine', 'Fernandina Beach', 'Orange Park'],
      'Memphis Metropolitan Area' => ['Memphis', 'TN','Bartlett', 'Collierville', 'Germantown'],
      'Oklahoma City Metro' => ['Oklahoma City', 'OK', 'Norman', 'Edmond', 'Noble'],
      'Louisville Metropolitan Area' => ['Louisville', 'KY', 'Anchorage', 'Audubon Park'],
      'Richmond Metropolitan Area' => ['Richmond', 'VA', 'Petersburg', 'Colonial Heights'],
      'New Orleans Metropolitan Area' => ['New Orleans', 'LA', 'Kenner', 'Metairie'],
      'Greater Hartford' => ['Hartford', 'CT', 'Avon', 'Berlin'],
      'Research Triangle' => ['Raleigh', 'NC', 'Durham', 'Cary', 'Chapel Hill'],
      'Salt Lake City Metropolitan Area' => ['Salt Lake City', 'UT', 'Alta', 'Bluffdale', 'Coalville'],
      'Greater Birmingham' => ['Birmingham', 'AL', 'Hoover', 'Talladega'],
      'Buffalo-Niagara Falls Metropolitan Area' => ['Buffalo', 'NY', 'Niagara Falls', 'Tonawanda', 'North Tonawanda', 'Lackawanna'],
      'Rochester Metropolitan Area' => ['Rochester', 'NY', 'Greece', 'Irondequoit']
    }

    regions = cities.keys
    regions.each do |region_name|

      context "checking #{region_name}" do
        before(:each, :run => true) do
            @range = 100 
            @city_array = cities[region_name][2..(cities[region_name].length - 1)] 
            @region_city = cities[region_name][0]
            @region_state = cities[region_name][1]
            @listing_sites = []
            @city_array.each do |city_name|
              city = FactoryGirl.create :site, name: city_name, site_type_code: 'city'
              lat, lng = Geocoder.coordinates(city_name + ',' + @region_state)
              city.contacts.create FactoryGirl.attributes_for :contact, city: city_name, state: @region_state, lat: lat, lng: lng
              listing = FactoryGirl.create(:listing, site_id: city.id, category_id: 1)
              @listing_sites.push(listing.site_id)
            end
            @region = FactoryGirl.create(:site, name: region_name, site_type_code: 'region')
            lat, lng = Geocoder.coordinates(@region_city + ',' + @region_state)
            @region.contacts.create FactoryGirl.attributes_for :contact, city: @region_city, state: @region_state, lat: lat, lng: lng
        end

        it "renders all pixis in its cities", :run => true do
          site_ids = []
          Listing.get_by_city(1, @region.id, true).each do |listing|
              site_ids.push(listing.site_id)
          end
          expect(site_ids.sort).to eql(@listing_sites)
        end

        it "only includes pixis for its cities", :run => true do
          expect(Listing.get_by_city(1, @region.id, true).length).to eql(@city_array.length)
        end
      end
      context "checking that renders no pixis when none in any city" do
        it "renders no pixis when none in any city" do
          empty_region = FactoryGirl.create(:site, name: 'empty_region_0', site_type_code: 'region')
          expect(Listing.get_by_city(1, empty_region, true)).to be_empty
        end
      end
    end
  end

  describe "url" do
    before :each, run: true do
      @site.site_url = @site.name 
      @site.site_type_code = 'pub'
      @site.save!
    end

    it 'generates url' do
      site2 = create :site, site_type_code: 'pub'
      expect(site2.url).to eq site2.name.downcase.gsub!(/\s+/, "")
    end

    it 'generates unique url', run: true do
      site2 = create :site, name: @site.name, site_type_code: 'pub'
      expect(site2.url).not_to eq @site.url
    end

    it 'shows full url path', run: true do
      expect(@site.site_url).to eq 'localhost:3000/pub/' + @site.url
    end
  end

  describe 'set_flds' do
    it 'does not sets url' do
      site = build :site 
      site.save!
      expect( site.url ).to be_blank
    end
    it 'calls set_flds' do
      site = build :site, site_type_code: 'pub' 
      site.should_receive(:set_flds)
      site.save
    end
  end

  describe "get by url", url: true do
    it_behaves_like 'a url', 'Site', :site, false
  end
end
