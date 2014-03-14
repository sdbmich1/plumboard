module LocationManager
  # used to manage geolocation

  # get location name
  def self.get_loc_name ip, loc
    if loc.blank?
      @ip = Rails.env.development? || Rails.env.test? ? '24.4.199.34' : ip
      @area = Geocoder.search(@ip)
      @loc_name = Contact.near([@area.first.latitude, @area.first.longitude]).first.city rescue nil
    else
      @loc_name = Site.find(loc).name rescue nil
    end
  end

  # get location id
  def self.get_location loc_name
    @loc = Site.find_by_name(loc_name).id rescue nil
  end
end
