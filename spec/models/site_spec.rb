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

  describe 'get_nearest_region' do
    before(:each, :run => true) do
      @site1 = create :site, name: 'Detroit', org_type: 'city'
      @site1.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI', zip: '48238'
      @site2 = create :site, name: 'Metro Detroit', org_type: 'region'
    end

    it "finds nearest region", :run => true do
      expect(Site.get_nearest_region('Detroit')).to include('Detroit')
    end

    it "doesn't find nearest region" do
      @site2 = create :site, name: 'SF Bay Area', org_type: 'region'
      expect(Site.get_nearest_region('Detroit')).to include('SF Bay Area')
      expect(Site.get_nearest_region('')).to include('SF Bay Area')
    end
  end

  describe 'check_org_type' do

    it 'finds site w/ org type' do
      site = create :site, name: 'Detroit', org_type: 'region'
      expect(Site.check_org_type(['city','region'])).not_to be_nil
    end

    it 'does not find site w/ org type' do
      site = create :site, name: 'Detroit', org_type: 'region'
      expect(Site.check_org_type(['city'])).to be_empty
    end
  end

  describe 'regions' do
    before(:each) do
      Geocoder.configure(:timeout => 30)
    end
    
    cities = {
      'New York Metropolitan Area' => ['New York City', 'NY', 'Rye', 'New Rochelle', 'Poughkeepsie', 'Newburgh'],
      'Los Angeles Metropolitan Area' => ['Los Angeles', 'CA', 'Anaheim', 'Santa Ana', 'Irvine', 'Glendale', 'Huntington Beach', 'Santa Clarita'],
      'Chicagoland' => ['Chicago', 'IL', 'Arlington Heights', 'Berwyn', 'Cicero', 'DeKalb', 'Des Plaines', 'Evanston'],
      'Dallas/Fort Worth Metroplex' => ['Dallas', 'TX', 'Fort Worth', 'Arlington', 'Plano', 'Irving', 'Frisco', 'McKinney', 'Carrollton', 'Denton', 'Garland', 'Richardson'],
      'Greater Houston' => ['Houston', 'TX', 'The Woodlands', 'Sugar Land', 'Baytown', 'Conroe'],
      'Delaware Valley' => ['Philadelphia', 'PA', 'Philadelphia', 'Reading'],
      'Washington Metropolitan Area' => ['Washington', 'D.C.', 'Washington'],
      'Miami Metropolitan Area' => ['Miami', 'FL', 'Fort Lauderdale', 'Hialeah', 'Miramar', 'Pembroke Pines'],
      'Metro Atlanta' => ['Atlanta', 'GA', 'Sandy Springs', 'Roswell', 'Johns Creek', 'Alpharetta', 'Marietta', 'Smyrna'],
      'Greater Boston' => ['Boston', 'MA', 'Boston', 'Cambridge', 'Framingham', 'Quincy'],
      'Valley of the Sun' => ['Phoenix', 'AZ', 'Mesa', 'Chandler', 'Glendale', 'Scottsdale', 'Gilbert'],
      'Inland Empire' => ['Riverside', 'CA', 'San Bernardino', 'Fontana', 'Moreno Valley', 'Rancho Cucamonga', 'Ontario', 'Corona', 'Victorville', 'Murrieta', 'Temecula'],
      'Seattle Metro' => ['Seattle', 'WA', 'Tacoma', 'Bellevue', 'Everett'],
      'Minneapolis-Saint Paaul' => ['Minneapolis', 'MN', 'Saint Paul', 'Bloomington', 'Brooklyn Park', 'Plymouth'],
      'San Diego County' => ['San Diego', 'CA', 'Carlsbad', 'Chula Vista', 'Escondido', 'Oceanside'],
      'Tampa Bay Area' => ['Tampa', 'FL', 'St. Petersburg', 'Clearwater', 'Brandon'],
      'Greater St. Louis' => ['St. Louis', 'MO', 'Berger', 'Arnold', 'Barnhart', 'Cottleville'],
      'Central Maryland' => ['Baltimore', 'MD', 'Columbia', 'Towson'],
      'Denver Metropolitan Area' => ['Denver', 'CO', 'Arvada', 'Aurora', 'Centennial'],
      'Pittsburgh Metropolitan Area' => ['Pittsburgh', 'PA', 'Indiana', 'Jeannette', 'Latrobe', 'Lower Burrell'],
      'Charlotte Metro' => ['Charlotte', 'NC', 'Concord', 'Gastonia', 'Cornelius', 'Hickory'],
      'Portland Metropolitan Area' => ['Portland', 'OR', 'Beaverton', 'Gresham', 'Hillsboro'],
      'Greater San Antonio' => ['San Antonio', 'TX', 'New Braunfels', 'Schertz', 'Seguin'],
      'Metro Orlando' => ['Orlando', 'FL', 'Kissimmee', 'Sanford', 'Tavares', 'Winter Park'],
      'Greater Sacramento' => ['Sacramento', 'CA', 'Roseville', 'Yuba City', 'South Lake Tahoe'],
      'Greater Cincinnati' => ['Cincinnati', 'OH', 'Hamilton', 'Middletown', 'Fairfield', 'Mason'],
      'Greater Cleveland' => ['Cleveland', 'OH', 'Parma', 'Lorain', 'Elyria', 'Lakewood'],
      'Kansas City Metropolitan Area' => ['Kansas City', 'MO', 'Independence', "Lee's Summit", 'Blue Springs'],
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
      'Richmond Metropolitan Area' => ['Richmond', 'VA', 'Petersburg', 'Hopewell', 'Colonial Heights'],
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
              city = FactoryGirl.create :site, name: city_name, org_type: 'city'
              lat, lng = Geocoder.coordinates(city_name + ',' + @region_state)
              city.contacts.create FactoryGirl.attributes_for :contact, city: city_name, state: @region_state, lat: lat, lng: lng
              listing = FactoryGirl.create(:listing, site_id: city.id)
              @listing_sites.push(listing.site_id)
            end
            @region = FactoryGirl.create(:site, name: region_name, org_type: 'region')
            lat, lng = Geocoder.coordinates(@region_city + ',' + @region_state)
            @region.contacts.create FactoryGirl.attributes_for :contact, city: @region_city, state: @region_state, lat: lat, lng: lng
        end

        it "renders all pixis in its cities", :run => true do
          site_ids = []
          Listing.active_by_region(@region_city, @region_state, 1, @range).each do |listing|
              site_ids.push(listing.site_id)
          end
          expect(site_ids.sort).to eql(@listing_sites)
        end

        it "only includes pixis for its cities", :run => true do
          expect(Listing.active_by_region(@region_city, @region_state, 1, @range).length).to eql(@city_array.length)
        end

        it "renders no pixis when none in any city" do
          expect(Listing.active_by_region(@region_city, @region_state, 1, @range)).to be_nil
        end
      end
    end
  end
end


