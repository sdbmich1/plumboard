module LocationManager
  # used to manage geolocation
  include Area

  # get location name
  def self.get_loc_name ip, loc, zip=''
    if loc.blank?
      @loc_name = zip.blank? ? get_loc_name_by_ip(ip) : zip.to_region(:city => true)
    else
      @loc_name = Site.find(loc).name rescue nil
    end
  end

  # get location id
  def self.get_loc_id loc_name, zip=nil
    loc_name ||= zip.to_region(:city => true) if zip
    @loc = Site.find_by_name(loc_name).id rescue nil
  end

  # get area long, lat
  def self.get_lat_lng ip
    @ip = Rails.env.development? || Rails.env.test? ? '24.4.199.34' : ip
    @area = Geocoder.search(@ip)
    [@area.first.latitude, @area.first.longitude] rescue nil
  end

  # get area long, lat by location
  def self.get_lat_lng_by_loc loc
    @area = Geocoder.search(loc)
    [@area.first.latitude, @area.first.longitude] rescue nil
  end

  # get location name by ip
  def self.get_loc_name_by_ip ip
    @loc_name = Contact.near(get_lat_lng(ip)).first.city rescue nil
  end

  # get home zip
  def self.get_home_zip loc_name
    city, state = loc_name.split(', ')[0], loc_name.split(', ')[1] rescue nil
    state_code = State.find_by_state_name(state).code rescue nil
    loc = [city, state_code].join(', ') if state_code
    loc.to_zip.first rescue nil
  end

  # get list of site ids
  def self.get_site_list loc, range=60
    site = Site.check_site(loc, ['city', 'region'])
    if site
      @contact = site.contacts.first

      if site.is_city?
        @slist = Contact.get_sites(@contact.city, @contact.state)
      else
        loc = [@contact.city, @contact.state].join(', ') if @contact.city && @contact.state
        @slist = Contact.proximity(nil, range, loc, true) if loc 
      end
    end
    @slist || loc
  end

  # get region
  def self.get_region loc, range=60
    Site.get_nearest_region loc, range
  end
end
