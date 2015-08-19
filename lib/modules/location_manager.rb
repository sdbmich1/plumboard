require 'open-uri'
require 'json'
module LocationManager
  # used to manage geolocation
  include Area, ControllerManager

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
    loc_name ||= PIXI_LOCALE
    @loc = Site.find_by_name(loc_name).id rescue nil
  end

  # get area long, lat
  def self.get_lat_lng ip
    @ip = Rails.env.development? || Rails.env.test? ? '24.4.199.34' : ip
    @area = Geocoder.search(@ip).first rescue nil
    [@area.latitude, @area.longitude] rescue nil
  end

  # get long, lat by zip
  def self.get_lat_lng_by_zip zip
    zip.to_latlon rescue nil
  end

  # get area long, lat by location
  def self.get_lat_lng_by_loc loc
    @area = Geocoder.search(loc).first rescue nil
    [@area.latitude, @area.longitude] rescue nil
  end

  # get area long, lat by site 
  def self.get_lat_lng_by_site id
    loc = Site.where(id: id).first 
    @area = loc.contacts.first rescue nil
    [@area.lat, @area.lng] rescue nil
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
  def self.get_site_list loc, range=100
    site = Site.check_site(loc, ['city', 'region'])
    if site
      contact = site.contacts.first
      loc = [contact.city, contact.state].join(', ') if contact.city && contact.state
      @slist = build_list site, contact, loc, range
    end
    @slist || loc
  end

  def self.build_list site, contact, loc, range
    if site.is_city?
      Contact.get_sites(contact.city, contact.state) rescue nil
    else
      Contact.proximity(nil, range, loc, true) if loc 
    end
  end

  # get region
  def self.get_region loc, range=60
    Site.get_nearest_region loc, range
  end

  # location setup
  def self.setup ip, loc, loc_name, zip
    loc_name ||= get_loc_name ip, loc, zip
    loc ||= get_loc_id(loc_name, zip)
    return [loc, loc_name]
  end

  def self.get_google_lng_lat loc
    url = ['http://maps.googleapis.com/maps/api/geocode/json?address=', loc.gsub!(/\s+/, "+"),'&sensor=false'].join('')
    str = parse_lat_lng JSON.parse(open(url).read)
  end

  def self.parse_lat_lng str
    if str
      [str["results"][0]["geometry"]["location"]["lat"], str["results"][0]["geometry"]["location"]["lng"]]  
    else
      nil
    end
  end

  def self.get_loc_by_url url
    Site.get_by_url(url).id 
  end

  # get loc id based on region name or url
  def self.retrieve_loc action_name, request
    if ControllerManager::public_url?(action_name) 
      get_loc_by_url(ControllerManager::parse_url request) rescue get_loc_id(PIXI_LOCALE)
    else
      get_loc_id(PIXI_LOCALE)
    end
  end

  def self.is_pub? sid
    Site.find(sid).is_pub? rescue nil
  end
end
