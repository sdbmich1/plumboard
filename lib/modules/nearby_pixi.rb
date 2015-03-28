module NearbyPixi
  # used to find nearby pixis

  # user ip address to find nearby sites and accompanying pixis
  def self.find_by_location ip, range=25

    # find nearby places by ip address
    places = Contact.near(ip, range, order: :distance).get_by_type('Site').includes(:contactable)

    if places.blank?
      Listing.active
    else
      list = []

      # get site ids
      places.map {|p| list << p.contactable.id}

      # reset list
      list.flatten! 1

      # get pixis
      Listing.active.where site_id: list.uniq
    end
  end
end

