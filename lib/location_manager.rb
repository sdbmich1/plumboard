module LocationManager
  # used to manage geolocation
  include Area

  # get location name
  def self.get_loc_name ip, loc, zip
    if loc.blank?
      @loc_name = zip.blank? ? get_loc_name_by_ip(ip) : zip.to_region(:city => true)
    else
      @loc_name = Site.find(loc).name rescue nil
    end
  end

  # get location id
  def self.get_loc_id loc_name, zip
    loc_name ||= zip.to_region(:city => true) if zip
    @loc = Site.find_by_name(loc_name).id rescue nil
  end

  # get location name by ip
  def self.get_loc_name_by_ip ip
    @ip = Rails.env.development? || Rails.env.test? ? '24.4.199.34' : ip
    @area = Geocoder.search(@ip)
    @loc_name = Contact.near([@area.first.latitude, @area.first.longitude]).first.city rescue nil
  end

  # get home zip
  def self.get_home_zip loc_name
    city, state = loc_name.split(', ')[0], loc_name.split(', ')[1] rescue nil
    state_code = State.find_by_state_name(state).code rescue nil
    loc = [city, state_code].join(', ') if state_code
    loc.to_zip.first rescue nil
  end
end
