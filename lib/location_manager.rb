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
end
