module NearbyPixi
  # used to find nearby pixis

  # user ip address to find nearby sites and accompanying pixis
  def self.find_by_location ip, range=10

    # find nearby places by ip address
    unless places = Contact.near(ip, range, order: :distance).get_by_type('Site').first
      Listing.active
    else
      places.contactable.active_listings
    end
  end
end
